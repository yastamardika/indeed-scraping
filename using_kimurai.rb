require 'kimurai'
require 'uri'

class JobScraper < Kimurai::Base
    @name = 'eng_job_scraper'
    @start_urls = ["https://www.indeed.com/jobs?q=software+engineer&l=New+York%2C+NY"]
    @engine = :mechanize   
    @@jobs = []
    @@all = []

    def scraping_page
        doc = browser.current_response
        returned_job = doc.css("td#resultsCol")
        to_scrap = returned_job.css('div#mosaic-zone-jobcards > div#mosaic-provider-jobcards')
        # puts to_scrap
        returned_job.css('div#mosaic-zone-jobcards > div#mosaic-provider-jobcards > a.resultWithShelf').each do |char_element|
            id = "krm-#{rand(1000000..9999999)}"
            root = char_element.css('div.slider_container > div.slider_list > div.slider_item > div.job_seen_beacon')
            title = char_element.css('h2.jobTitle > span').text.gsub(/\n/, "")
            link = "https://indeed.com" + char_element.attributes["href"].value.gsub(/\n/, "")
            # description = char_element.css('div.summary').text.gsub(/\n/, "")
            company = char_element.css('span.companyName').text.gsub(/\n/, "")
            location = char_element.css('table.jobCard_mainContent > tbody > tr > td.resultContent > div.company_location > div.companyLocation').text.gsub(/\n/, "")
            salary = char_element.css('table.jobCard_mainContent > tbody > tr > td.resultContent > div.metadataContainer').text.gsub(/\n/, "")
            requirements = char_element.css('table.jobCardShelfContainer > tbody > tr.underShelfFooter > td > div.result-footer > div.job-snippet > ul').text.gsub(/\n/, "")
            # puts requirements
            # creating a job object
            job = {id: id,title: title,link: link, company: company, location: location, salary: salary, requirements: requirements}
            job_in_csv = [id, title, link, company, location, salary, requirements]
            @@jobs << job if !@@jobs.include?(job)
            @@all << job_in_csv if !@@all.include?(job_in_csv)
            # puts @@jobs
        end 
    end
    def parse(res, url:, data: {})
        scraping_page
        # next_page = browser.find('/html/body/table[2]/tbody/tr/td/table/tr/td[@id="resultsCol"]/nav[@role="navigation"]/div/ul/li[6]/a/span').click
        next_page = browser.find('/html/body/table[2]/tbody/tr/td/table/tr/td[@id="resultsCol"]/nav[@role="navigation"]/div/ul/li[6]/a/span')
        p next_page
        next_page.click
        num = 2
        scrap_all = true

        while scrap_all
            scraping_page
            if browser.current_response.css('div#popover-background') || browser.current_response.css('div#popover-input-locationtst')
                browser.refresh 
            end

            begin
                click = browser.find('/html/body/table[2]/tbody/tr/td/table/tr/td[@id="resultsCol"]/nav[@role="navigation"]/div/ul/li[6]')
                p click
                click.click
            rescue => exception
                scrap_all = false
            end
        end
        # 10.times do
        #     browser.visit("https://www.indeed.com/jobs?q=software+engineer&l=New+York,+NY&start=#{num}0")
        #     scraping_page
        #     num += 1
        # end
        # puts @@jobs
        attrib = @@jobs.map(&:keys).flatten.uniq
        CSV.open("indeed.csv", mode= "wb", {headers: attrib}) do |csv|
            csv << attrib
            @@jobs.each do |item|
                csv << attrib.map { |attr| item[attr] }
            end
        end
        File.open("indeed.json","w") do |f|
            f.write(JSON.pretty_generate(@@jobs))
        end
        @@jobs
    end

   
end

JobScraper.crawl!
