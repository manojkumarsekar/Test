Feature: BNP DNA Report Performance Attribution ABOR/IBOR Historical Report Downloads
		
		@workingon
    Scenario: Login to BNP DNA

				Given I open a BNP DNA web session defined in "bnp.dna.web.session"

				Then I select the BNP DNA service "FarEast - Equity L3 Histo Load Data From UAT"
				Then I switch to the next browser tab
				And I pause for 15 seconds

				
		@workingon
    Scenario Outline: Download reports

				Then I select the BNP DNA "Dashboard" tab
				And I take a screenshot

				Then I choose BNP DNA Dashboard portfolio "<fund-name>" with period of "1 Month" and the date "1/31/2017"
				And I choose BNP DNA Dashboard report scope for "Alternative By SECTOR"
				And I export the BNP DNA Pocket Level Attribution into CSV file with name "BNP_DNA_<fund-id>_<scope-cd>_<period-cd>.csv" into location "testout/evidence/performance"
				Then I expect the CSV file to contain below column headers:
						|	Fund ID                               |
						|	Asset Class                           |
						|	Fund Code                             |
						|	Accounting Code                       |
						|	Fund Name                             |
						|	Benchmark Name                        |
						|	Currency                              |
						|	Value Date                            |
						|	ShareClass AUM (M.)                   |
						|	1M Fund Net Return                    |
						|	1M Fund Gross Return                  |
						|	1M Fund Pri. Benchmark Return         |
						|	1M Fund Net Relative Return           |
						|	1M Fund Gross Relative Return         |
						|	3M Date                               |
						|	3M Fund Net Return                    |
						|	3M Fund Gross Return                  |
						|	3M Fund Pri. Benchmark Return         |
						|	3M Fund Net Relative Return           |
						|	3M Fund Gross Relative Return         |
						|	6M Date                               |
						|	6M Fund Net Return                    |
						|	6M Fund Gross Return                  |
						|	6M Fund Pri. Benchmark Return         |
						|	6M Fund Net Relative Return           |
						|	6M Fund Gross Relative Return         |
						|	FYTD Date                             |
						|	FYTD Fund Net Return                  |
						|	FYTD Fund Gross Return                |
						|	FYTD Fund Pri. Benchmark Return       |
						|	FYTD Fund Net Relative Return         |
						|	FYTD Fund Gross Relative Return       |
						|	YTD Date                              |
						|	YTD Fund Net Return                   |
						|	YTD Fund Gross Return                 |
						|	YTD Fund Pri. Benchmark Return        |
						|	YTD Fund Net Relative Return          |
						|	YTD Fund Gross Relative Return        |
						|	1Y Date                               |
						|	1Y Fund Net Return                    |
						|	1Y Fund Gross Return                  |
						|	1Y Fund Pri. Benchmark Return         |
						|	1Y Fund Net Relative Return           |
						|	1Y Fund Gross Relative Return         |
						|	2Y Date                               |
						|	2Y Fund Net Return (Ann.)             |
						|	2Y Fund Gross Return (Ann.)           |
						|	2Y Fund Pri. Benchmark Return (Ann.)  |
						|	2Y Fund Net Relative Return (Ann.)    |
						|	2Y Fund Gross Relative Return (Ann.)  |
						|	3Y Date                               |
						|	3Y Fund Net Return (Ann.)             |
						|	3Y Fund Gross Return (Ann.)           |
						|	3Y Fund Pri. Benchmark Return (Ann.)  |
						|	3Y Fund Net Relative Return (Ann.)    |
						|	3Y Fund Gross Relative Return (Ann.)  |
						|	4Y Date                               |
						|	4Y Fund Net Return (Ann.)             |
						|	4Y Fund Gross Return (Ann.)           |
						|	4Y Fund Pri. Benchmark Return (Ann.)  |
						|	4Y Fund Net Relative Return (Ann.)    |
						|	4Y Fund Gross Relative Return (Ann.)  |
						|	5Y Date                               |
						|	5Y Fund Net Return (Ann.)             |
						|	5Y Fund Gross Return (Ann.)           |
						|	5Y Fund Pri. Benchmark Return (Ann.)  |
						|	5Y Fund Net Relative Return (Ann.)    |
						|	5Y Fund Gross Relative Return (Ann.)  |
						|	7Y Date                               |
						|	7Y Fund Net Return (Ann.)             |
						|	7Y Fund Gross Return (Ann.)           |
						|	7Y Fund Pri. Benchmark Return (Ann.)  |
						|	7Y Fund Net Relative Return (Ann.)    |
						|	7Y Fund Gross Relative Return (Ann.)  |
						|	10Y Date                              |
						|	10Y Fund Net Return (Ann.)            |
						|	10Y Fund Gross Return (Ann.)          |
						|	10Y Fund Pri. Benchmark Return (Ann.) |
						|	10Y Fund Net Relative Return (Ann.)   |
						|	10Y Fund Gross Relative Return (Ann.) |
						|	SI Date                               |
						|	SI Fund Net Return                    |
						|	SI Fund Gross Return                  |
						|	SI Fund Pri. Benchmark Return         |
						|	SI Fund Net Relative Return           |
						|	SI Fund Gross Relative Return         |
						|	SI Fund Net Return (Ann.)             |
						|	SI Fund Gross Return (Ann.)           |
						|	SI Fund Pri. Benchmark Return (Ann.)  |
						|	SI Fund Net Relative Return (Ann.)    |
						|	SI Fund Gross Relative Return (Ann.)  |

		Examples:
				| fund-id |                       fund-name                           | period     | type           | period-cd | scope-cd |
				| Fund00  | ASIA REIT MASTER FUND SERIES IX OF KOKUSAI TRUST          | 1 Month    | SECTOR_COUNTRY |    1M     |  SECTOR  |
				| Fund00  | ASIA REIT MASTER FUND SERIES IX OF KOKUSAI TRUST          | 12 Months  | SECTOR_COUNTRY |   12M     |  SECTOR  |
				| Fund01  | EASTSPRING INVESTMENTS - ASIAN DYNAMIC FUND               | 1 Month    | SECTOR_ONLY    |    1M     |  SECTOR  |
				| Fund01  | EASTSPRING INVESTMENTS - ASIAN DYNAMIC FUND               | 127 Months | SECTOR_ONLY    |  127M     |  SECTOR  |
				| Fund02  | EASTSPRING INVESTMENTS - ASIAN EQUITY FUND                | 1 Month    | SECTOR_ONLY    |    1M     |  SECTOR  |
				| Fund03  | EASTSPRING INVESTMENTS - ASIAN PROPERTY SECURITIES FUND   | 1 Month    | SECTOR_ONLY    |    1M     |  SECTOR  |
				| Fund04  | EASTSPRING INVESTMENTS - DEVELOPED AND EMERGING ASIA EQUI | 1 Month    | SECTOR_ONLY    |    1M     |  SECTOR  |
				| Fund05  | EASTSPRING INVESTMENTS - GLOBAL LOW VOLATILITY EQUITY FUN | 1 Month    | SECTOR_ONLY    |    1M     |  SECTOR  |
				| Fund06  | EASTSPRING INVESTMENTS - GREATER CHINA EQUITY FUND        | 1 Month    | SECTOR_ONLY    |    1M     |  SECTOR  |
				| Fund07  | EASTSPRING INVESTMENTS - INDIA DISCOVERY FUND             | 1 Month    | SECTOR_ONLY    |    1M     |  SECTOR  |
				| Fund08  | EASTSPRING INVESTMENTS - INDIA EQUITY FUND                | 1 Month    | SECTOR_ONLY    |    1M     |  SECTOR  |
				| Fund09  | INDIA EQUITY PORTFOLIO - FUND 225                         | 1 Month    | SECTOR_ONLY    |    1M     |  SECTOR  |
				| Fund10  | PRUDENTIAL ASSURANCE WITH PROFITS - ASIA + AUSTRALIA EQUI | 1 Month    | SECTOR_ONLY    |    1M     |  SECTOR  |
				| Fund11  | SGIF                                                      | 1 Month    | SECTOR_COUNTRY |    1M     |  SECTOR  |  



# Additional Gherkin statements avaiable:
#				And I choose BNP DNA Dashboard report scope for "Country"
#				And I export the BNP DNA Securities Level Attribution into CSV file with name "<filename>" into location "<dest-dir>"

#				And I set the variable "targetFilename" to ""
		