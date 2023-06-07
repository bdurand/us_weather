# frozen_string_literal: true

require_relative "../spec_helper"

describe USWeather::Station do
  describe "refesh!" do
    it "fetches all observation stations and saves them"
  end

  describe "sunrise" do
    it "returns the sunrise time"
  end

  describe "sunset" do
    it "returns the sunset time"
  end

  describe "latest_observation" do
    it "returns the latest observation"
  end

  describe "latest_observation!" do
    it "fetches the latest observation and saves it"
  end
end
