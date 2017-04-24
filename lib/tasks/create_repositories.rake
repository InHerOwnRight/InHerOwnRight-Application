namespace :create_repositories do
  desc "Create records and Dublin Core parts from raw records"

  task all: :environment do
    repo_list = [
    ["Temple University Libraries", "1210 Polett Walk, Philadelphia, PA 19122", "diglib@temple.edu", "http://digital.library.temple.edu/"],
    ["Barbara Bates Center for the Study of the History of Nursing | University of Pennsylvania School of Nursing", "Suite 2U, Claire M. Fagin Hall, 418 Curie Boulevard, Philadelphia, PA  19104-4217", "nhistory@nursing.upenn.edu", "https://www.nursing.upenn.edu/history/archives-collections/"],
    ["Friends Historical Library: Swarthmore College", "McCabe Library, 500 College Avenue, Swarthmore, PA 19081", "http://www.swarthmore.edu/friends-historical-library", "friends@swarthmore.edu"],
    ["Haverford College Library, Quaker & Special Collections", "Haverford College, 370 Lancaster Ave., Haverford, PA 19041", "hc-special@haverford.edu", "http://library.haverford.edu/places/special-collections/"],
    ["The Library Company of Philadelphia", "1314 Locust Street, Philadelphia, PA 19107", "cking@librarycompany.org", "http://www.librarycompany.org/"],
    ["Historical Society of Pennsylvania", "1300 Locust Street, Philadelphia, PA 19107", "aparks@hsp.org", "http://hsp.org/"],
    ["Archives and Special Collections Drexel University College of Medicine", "2900 West Queen Lane, Philadelphia, PA 19129", "archives@drexelmed.edu", "http://archives.drexelmed.edu/index.php"]
    ]

    repo_list.each do |repo|
      repository = Repository.new
      repository.name = repo[0]
      repository.address = repo[1]
      repository.email = repo[2]
      repository.url = repo[3]
      repository.save
    end
  end
end