# require this manually and invoke it like this:
# require './lib/active_storage_migration'; migrate(:local, :amazon)
module ActiveStorage
  class Downloader #:nodoc:
    def initialize(blob, tempdir: nil)
      @blob    = blob
      @tempdir = tempdir
    end

    def download_blob_to_tempfile
      open_tempfile do |file|
        download_blob_to file
        verify_integrity_of file
        yield file
      end
    end

    private
      attr_reader :blob, :tempdir

      def open_tempfile
        file = Tempfile.open([ "ActiveStorage-#{blob.id}-", blob.filename.extension_with_delimiter ], tempdir)

        begin
          yield file
        ensure
          file.close!
        end
      end

      def download_blob_to(file)
        file.binmode
        blob.download { |chunk| file.write(chunk) }
        file.flush
        file.rewind
      end

      def verify_integrity_of(file)
        unless Digest::MD5.file(file).base64digest == blob.checksum
          raise ActiveStorage::IntegrityError
        end
      end
  end
end

module AsDownloadPatch
  def open_to_tempfile(tempdir: nil, &block)
    ActiveStorage::Downloader.new(self, tempdir: tempdir).download_blob_to_tempfile(&block)
  end
end

# This isn't happening the way we expect, just do it at the beginning of #migrate
# Rails.application.config.to_prepare do
#   ActiveStorage::Blob.send(:include, AsDownloadPatch)
# end

def migrate(from, to)
  ActiveStorage::Blob.send(:include, AsDownloadPatch)
  # configs = Rails.configuration.active_storage.service_configurations # looks like this was introduced in Rails 6
  configs = YAML.load(ERB.new(File.read("#{Rails.root}/config/storage.yml")).result(binding))
  from_service = ActiveStorage::Service.configure from, configs
  to_service   = ActiveStorage::Service.configure to, configs

  ActiveStorage::Blob.service = from_service

  puts "#{ActiveStorage::Blob.count} Blobs to go..."
  # ActiveStorage::Blob.find_each do |blob|
  blobs_to_migrate = ActiveStorage::Blob.all.select{|b| b.download rescue nil}.compact
  blobs_to_migrate.each do |blob|
    print '.'
    blob.open_to_tempfile do |tf|
      checksum = blob.checksum
      to_service.upload(blob.key, tf, checksum: checksum)
    end
  end
end
