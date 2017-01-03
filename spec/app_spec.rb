require "./lib/github_user"

RSpec.describe "Sinatra Application" do
  describe "GET /" do
    it "displays the homepage" do
      get "/"

      expect(last_response).to be_ok
      expect(last_response.body).to include("Find a user's favourite coding language by entering their Github username below.")
    end
  end

  describe "POST /favourite_language" do
    let(:username) { 'jamesmarkcook' }

    context "user can be found" do
      let(:github_user_double) { double(GithubUser, favourite_languages: favourite_languages, username: username) }
      let(:favourite_languages) { [] }

      it "sends the favourite languages to the ResultsPresenter" do
        allow(GithubUser).to receive(:new).and_return github_user_double
        expect(ResultsPresenter).to receive(:new).with(username, favourite_languages).and_call_original
        post "/favourite_language", username: username
      end
    end

    context "user can't be found" do
      it "rescues the error and displays a helpful message" do
        allow(GithubUser).to receive(:new).and_raise GithubUser::NotFound
        post "/favourite_language", username: username
        expect(last_response.body).to include("Could not find user '#{username}'. Please try again.")
      end
    end

    context "username submitted is blank" do
      it "rescues the error and displays a helpful message" do
        post "/favourite_language", username: nil
        expect(last_response.body).to include("Username can't be blank.")
      end
    end
  end
end
