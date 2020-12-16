require "rails_helper"

RSpec.describe AdViewsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/ad_views").to route_to("ad_views#index")
    end

    it "routes to #show" do
      expect(get: "/ad_views/1").to route_to("ad_views#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/ad_views").to route_to("ad_views#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/ad_views/1").to route_to("ad_views#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/ad_views/1").to route_to("ad_views#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/ad_views/1").to route_to("ad_views#destroy", id: "1")
    end
  end
end
