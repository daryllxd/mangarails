
class MangasController < ApplicationController
  before_action :set_manga, only: [ :index]

    # @manga_service = nil
    # @manga = {}

  def index
    if params.has_key?(:page)
      page = params[:page]
    else
      page = 1
    end
    @paginated_volumes = []
    @paginated_volumes = Kaminari.paginate_array(@manga[:volumes]).page(page).per(10) if @manga.size > 0
  end

  def zip
      send_file params[:zip_path], :type=>"application/cbr", :x_sendfile=>true
  end

  def chapters
    @manga = session[:manga]
    @volume = @manga[:volumes][params[:volume].to_i][:volume]
    @chapters = @manga[:volumes][params[:volume].to_i][:chapter_list]
  end

  def downloaded_chapter
   @manga = session[:manga]
    base_link = params[:url].remove("/1.html")
    @directory = params[:url].remove("/1.html")
    @directory["http://mangafox.me/manga/"] = ""
    @zipfile_name = Rails.root.join('app', 'assets', 'images', @directory+".cbr").to_s

    unless File.exist?(@zipfile_name)

      #select
      page = Nokogiri::HTML(open(params[:url]))


      chapter_links = page.css('select.m option')
      images_size =  chapter_links.size/2 - 1

      chapters = []
      image_urls=[]

      if images_size > 0
        (1..images_size).each do |index|
          chapter_each_link= "#{base_link}/#{index.to_s}.html"
          chapter_each_link_page = Nokogiri::HTML(open(chapter_each_link))
          image_urls += [chapter_each_link_page.css('div.read_img img')[0]["src"]]
        end
        make_directory(@directory)
        image_filenames = []
        image_urls.each_with_index do |url,index|
          image_url = Rails.root.join('app', 'assets', 'images', @directory, "#{sprintf('%03d', index+1)}.jpg").to_s
          photo_download(url,image_url)
          image_filenames += [image_url]
        end
        zip_file(@zipfile_name,image_filenames)
        FileUtils.remove_dir(Rails.root.join('app', 'assets', 'images', @directory))

      end
    end
  end

  def make_directory(directory)
    unless File.directory?(Rails.root.join('app', 'assets', 'images', directory))
      FileUtils.mkdir_p(Rails.root.join('app', 'assets', 'images',directory))
    end
  end

  def download
    @volume = @manga[:volumes][params[:volume].to_i][:volume]
    @chapters = @manga[:volumes][params[:volume].to_i][:chapter_list]
  end

  def photo_download(url,image_url)
    download = open(url)
    IO.copy_stream(download, image_url)
  end

  def zip_file(zipfile_name,images)
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      images.each_with_index do |filename,index|
        zipfile.add("#{sprintf('%03d', index+1)}.jpg", filename)
      end
    end
  end

  private

  def set_manga
    @manga_service = MangasService.new
    if params.has_key?(:search)
      @manga = @manga_service.set_manga(params[:search])
    else
      @manga = @manga_service.manga
    end
     session[:manga] = @manga
  end

end
