require "./lib/github_user"

RSpec.describe "Sinatra Application" do
  describe "GET /" do
    it "displays the homepage" do
      get "/"

      expect(last_response).to be_ok
      expect(last_response.body).to include("Find your favourite programming language!")
    end
  end

  describe "POST /favourite_language" do
    let(:username) { 'jamesmarkcook' }

    context "user can be found" do
      context "has 1 or more public repos" do
        let(:github_user_double) { double(GithubUser, favourite_languages: favourite_languages, username: username) }

        before do
          allow(GithubUser).to receive(:new).with(username).and_return github_user_double
        end

        context "user has one favourite language" do
          let(:favourite_languages) { ["Ruby"] }

          it "displays the user's favourite language" do
            post "/favourite_language", username: username
            expect(last_response.body).to include("#{username}'s favourite language is Ruby")
          end
        end

        context "user has more than one favourite language" do
          let(:favourite_languages) { ["Ruby", "Javascript"] }

          it "displays the user's favourite languages" do
            post "/favourite_language", username: username
            expect(last_response.body).to include("#{username}'s favourite languages are Ruby, Javascript.")
          end
        end

        context "user doesn't have any public repos with language information" do
          let(:favourite_languages) { [] }

          it "displays a relevant message" do
            post "/favourite_language", username: username
            expect(last_response.body).to include("#{username} does not appear to have any public repos with language information.")
          end
        end
      end
    end

    context "user can't be found" do
      before do
        allow(GithubUser).to receive(:new).and_raise GithubUser::NotFound
      end

      it "rescues the error and displays a helpful message" do
        post "/favourite_language", username: username
        expect(last_response.body).to include("User could not be found.")
      end
    end
  end
end
