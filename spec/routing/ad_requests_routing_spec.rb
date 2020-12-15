require "rails_helper"

RSpec.describe AdRequestsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/ad_requests").to route_to("ad_requests#index")
    end

    it "routes to #show" do
      expect(get: "/ad_requests/1").to route_to("ad_requests#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/ad_requests").to route_to("ad_requests#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/ad_requests/1").to route_to("ad_requests#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/ad_requests/1").to route_to("ad_requests#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/ad_requests/1").to route_to("ad_requests#destroy", id: "1")
    end
  end
end
