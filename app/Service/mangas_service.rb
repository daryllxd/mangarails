class MangasService
  attr_accessor :manga

  def initialize
    @manga = {}
  end

  def set_manga(url)
    if url != nil
      page = Nokogiri::HTML(open(url))
      @manga[:title] = page.css('div#title h1')[0].text

      volume_list = page.css('div.slide')
      @manga[:volumes] = []
      volume_list.each do |volume|
        @manga[:volumes] << {volume:volume.css("h3.volume").text}
      end

      chapter_list = page.css('ul.chlist')

      chapter_list.each_with_index do |chapter,index|
           @manga[:volumes][index][:chapter_list] = chapter_list(chapter)
      end
    end
    return @manga

  end

  def chapters(index)
       @manga[:volumes][index]
  end
  
private

  def chapter_list(chapter)
    chapter_list = []
    chapter.css('li').each do |chapter|
       chapter_temp = chapter.css("a.tips")
       if chapter_temp
         chapter_list << { href:chapter_temp[0]["href"], text:chapter_temp.text }
       end
    end
    return chapter_list
  end


end
