require 'test_helper'

class PacsclCollectionTest < ActiveSupport::TestCase
  test "#easy_match_detailed_name matches M. Carey Thomas Papers" do
    names = ["M. Carey Thomas Papers, 1853-1935 --http://archives.tricolib.brynmawr.edu/repositories/6/archival_objects/98852",
             "M. Carey Thomas Papers, 1853-1935 --http://archives.tricolib.brynmawr.edu/resources/1db-thomas"]
    names.each do |name|
      easy_match_name = PacsclCollection.easy_match_detailed_name(name)
      assert_equal "M. Carey Thomas Papers, 1853-1935", easy_match_name
    end
  end

  test "#easy_match_detailed_name matches The Female Society of Philadelphia for the Relief and Employment of the Poor records" do
    names = ["The Female Society of Philadelphia for the Relief and Employment of the Poor records --https://archives.tricolib.brynmawr.edu/resources/__1302",
             "The Female Society of Philadelphia for the Relief and Employment of the Poor records --https://archives.tricolib.brynmawr.edu/resources/__1614"]
    names.each do |name|
      easy_match_name = PacsclCollection.easy_match_detailed_name(name)
      assert_equal "The Female Society of Philadelphia for the Relief and Employment of the Poor records", easy_match_name
    end
  end

  test "#easy_match_detailed_name matches Josiah White papers" do
    names = ["Josiah White papers --https://archives.tricolib.brynmawr.edu/resources/hcmc-1166",
             "Josiah White papers (HC.MC-1166) --http://archives.tricolib.brynmawr.edu/resources/hcmc-1166"]
    names.each do |name|
      easy_match_name = PacsclCollection.easy_match_detailed_name(name)
      assert_equal "Josiah White papers", easy_match_name 
    end
  end

  test "#easy_match_detailed_name matches Mary Whitall Worthington papers" do
    names = ["Mary Whitall Worthington papers, 1906-1911-- http://archives.tricolib.brynmawr.edu/repositories/6/resources/8664",
             "Mary Whitall Worthington papers, 1906-1911--\n      http://archives.tricolib.brynmawr.edu/repositories/6/resources/8664"]
    names.each do |name|
      easy_match_name = PacsclCollection.easy_match_detailed_name(name)
      assert_equal "Mary Whitall Worthington papers", easy_match_name 
    end
  end

  test "#easy_match_detailed_name matches Abby Hopper Gibbons Papers" do
    name = "Abby Hopper Gibbons Papers, SFHL-RG5-174 --http://archives.tricolib.brynmawr.edu/resources/5174ahgi"
    easy_match_name = PacsclCollection.easy_match_detailed_name(name)
    assert_equal "Abby Hopper Gibbons Papers", easy_match_name
  end

  test "#easy_match_detailed_name matches Mott Manuscripts" do
    name = "Mott Manuscripts, SFHL-MSS-035 --http://archives.tricolib.brynmawr.edu/resources/mott"
    easy_match_name = PacsclCollection.easy_match_detailed_name(name)
    assert_equal "Mott Manuscripts", easy_match_name
  end

  test "#easy_match_detailed_name matches Lewis-Fussell Family Papers" do
    name = "Lewis-Fussell Family Papers, SFHL-RG5-087 --http://archives.tricolib.brynmawr.edu/resources/5087lefu"
    easy_match_name = PacsclCollection.easy_match_detailed_name(name)
    assert_equal "Lewis-Fussell Family Papers", easy_match_name
  end

  test "#easy_match_detailed_name matches American Women's Hospital Service" do
    name = "American Women's Hospital Service, 1917-1920--ACC-144"
    easy_match_name = PacsclCollection.easy_match_detailed_name(name)
    assert_equal "American Women's Hospital Service", easy_match_name
  end
  
  test "#easy_match_detailed_name matches Caroline Katzenstein papers" do
    names = ["Caroline Katzenstein papers, Am .8996",
             "Caroline Katzenstein papers (Am.8996)"]
    names.each do |name|
      easy_match_name = PacsclCollection.easy_match_detailed_name(name)
      assert_equal "Caroline Katzenstein papers", easy_match_name 
    end
  end


end
