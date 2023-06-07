# frozen_string_literal: true

module USWeather
  module State
    FIPS_CODES = {
      "AL" => "01",
      "AK" => "02",
      "AZ" => "04",
      "AR" => "05",
      "CA" => "06",
      "CO" => "08",
      "CT" => "09",
      "DE" => "10",
      "FL" => "12",
      "GA" => "13",
      "HI" => "15",
      "ID" => "16",
      "IL" => "17",
      "IN" => "18",
      "IA" => "19",
      "KS" => "20",
      "KY" => "21",
      "LA" => "22",
      "ME" => "23",
      "MD" => "24",
      "MA" => "25",
      "MI" => "26",
      "MN" => "27",
      "MS" => "28",
      "MO" => "29",
      "MT" => "30",
      "NE" => "31",
      "NV" => "32",
      "NH" => "33",
      "NJ" => "34",
      "NM" => "35",
      "NY" => "36",
      "NC" => "37",
      "ND" => "38",
      "OH" => "39",
      "OK" => "40",
      "OR" => "41",
      "PA" => "42",
      "RI" => "44",
      "SC" => "45",
      "SD" => "46",
      "TN" => "47",
      "TX" => "48",
      "UT" => "49",
      "VT" => "50",
      "VA" => "51",
      "WA" => "53",
      "WV" => "54",
      "WI" => "55",
      "WY" => "56",
      "DC" => "11",
      "PR" => "72",
      "VI" => "74",
      "AS" => "60",
      "GU" => "66",
      "MP" => "69"
    }.freeze

    class << self
      def fips_code(abbr)
        FIPS_CODES[abbr.to_s.upcase]
      end
    end
  end
end
