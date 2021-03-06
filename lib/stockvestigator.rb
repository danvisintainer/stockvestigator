require "stockvestigator/version"

module Stockvestigator

  class StockCLI
    
    def call
      puts "Welcome to the Stockvestigator 3000"
      puts "Dow: #{index_prices[0][0]}: #{index_prices[0][1]}"
      puts "Nasdaq: #{index_prices[1][0]}: #{index_prices[1][1]}"
      puts "S+P: #{index_prices[2][0]}: #{index_prices[2][1]}"
    end

    def menu    
      puts "Enter a stock ticker symbol or type exit to close the program."
      input = gets.strip.downcase
      if input.downcase != "exit"
        display_stock_info(input)
      end
    end

    def index_prices
      html = Nokogiri::HTML(open("http://money.cnn.com/data/markets/"))
      indexes = [] 
      html.search("div.module-body.row.tickers li.column").each do |column|
        indexes << [column.search("span.ticker-points").text, 
                    column.search("span.posData").text.gsub("%", "% ")]
        
      end
      indexes
      
    end


    def display_stock_info(input)   
      scrape = Scraper.new(input)
      stock = StockQuote::Stock.quote("#{input}")
      if input.length > 5
        puts "Not a valid Stock."
        menu
      else
        system("clear")
        system("cowsay #{input.upcase}")
        puts "--------------------------------------"
        puts "Current Price: #{scrape.current_price}"
        puts "Change: #{stock.change} (#{stock.changein_percent})"  
        puts "Prev. Close: #{stock.previous_close}. Open: #{stock.open}"
        puts "Bid: #{stock.bid_realtime}. Ask: #{stock.ask_realtime}"
        puts "Earnings date: #{scrape.earnings_date}"
        puts "Day's Range: #{stock.days_range}. Year's Range: #{stock.year_range}"
        puts "Volume: #{stock.volume.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{','}")}"
        puts "Market Cap: #{stock.market_capitalization}"
        puts "P/E Ratio: #{stock.pe_ratio}. Earnings per share: #{stock.earnings_share}"
        stock.dividend_share != 0.0 ? (puts "Div. and Yield: #{stock.dividend_share} (#{stock.dividend_yield}%)") : (puts "No Dividend")
        puts "Similiar companies: #{scrape.competition}"
        puts ""

        scrape.get_headlines.each.with_index(1) do |article, i|
          puts "#{i}. #{article[0]}: #{article[2]}"
        end
    
        while true
          puts "Enter an article's number to view that article or type 'menu' to return to the main menu."
          input = gets.strip.downcase
          if input.to_i.between?(1, 10)
            open_page(scrape.get_headlines[input.to_i-1][1])
          elsif input == "menu"
            menu
            break
          elsif input == "exit"
            break
          else 
            puts "Not a valid selection."
          end
        end 
      end
    end

    def open_page(url)
      system("open", url)
    end
  end
end