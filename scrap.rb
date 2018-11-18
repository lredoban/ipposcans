require 'open-uri'
require 'nokogiri'
require 'json'

baseUrl = 'http://vf-scan.com/hajime-no-ippo/lirescan-hajime-no-ippo-'
chapters = []

(1..1216).each do |chapter|
    system('clear')
    puts chapter
    current = {"name" => chapter.to_s, "pages" => []}
    doc = Nokogiri::HTML(open(baseUrl + chapter.to_s))
    nPages = doc.at_css('.pagenation').css('a').length + 1
    (1..nPages).each do |p| 
        current['pages'].push(p < 10 ? '0' + p.to_s : p.to_s)
    end
    chapters.push(current)
end

File.open("public/temp.json","w") do |f|
    f.write({:chapters => chapters}.to_json)
end