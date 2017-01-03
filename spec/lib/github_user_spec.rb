require "./lib/github_user"

RSpec.describe GithubUser do
  let(:username)              { "jamesmarkcook" }
  let(:user_response)         { double("Octokit response", rels: { repos: repo_page_1_uri }, login: username) }

  #Page 1
  let(:repo_page_1_uri)       { double("Repo Page 1 URI", get: repo_page_1_response) }
  let(:repo_page_1_response)  { double("Repo Page 1 Response", data: repositories_1, rels: { next: repo_page_2_uri }) }
  let(:repositories_1)        { [] }

  # Page 2
  let(:repo_page_2_uri)       { double("Repo Page 2 URI", get: repo_page_2_response) }
  let(:repo_page_2_response)  { double("Repo  Page 2 Response", data: repositories_2, rels: { next: repo_page_3_uri}) }
  let(:repositories_2)        { [] }

  # Page 3
  let(:repo_page_3_uri)       { double("Repo Page 3 URI", get: repo_page_3_response) }
  let(:repo_page_3_response)  { double("Repo  Page 3 Response", data: repositories_3, rels: {}) }
  let(:repositories_3)        { [] }

  subject { GithubUser.new(username) }

  it "retrieves user information from Github API upon initialisation and assigns it to @user" do
    expect(Octokit).to receive(:user).with(username).and_return user_response
    subject
    expect(subject.instance_variable_get("@user")).to eq user_response
  end

  context "when the github username is not found" do
    it "raises a GithubUser::NotFound error" do
      allow(Octokit).to receive(:user).and_raise(Octokit::NotFound)
      expect{ subject }.to raise_error(GithubUser::NotFound)
    end
  end

  context "when the username is blank" do
    context "by being nil" do
      let(:username) { nil }

      it "raises a GithubUser::InvalidParams error" do
        expect(Octokit).not_to receive(:user)
        expect{ subject }.to raise_error(GithubUser::InvalidParams)
      end
    end

    context "by being an empty string" do
      let(:username) { "" }

      it "raises a GithubUser::InvalidParams error" do
        expect(Octokit).not_to receive(:user)
        expect{ subject }.to raise_error(GithubUser::InvalidParams)
      end
    end
  end

  describe "username" do
    it "returns the user's github username" do
      allow(Octokit).to receive(:user).and_return user_response
      expect(subject.username).to eq username
    end
  end

  describe "favourite_languages" do
    Repository = Struct.new(:name, :language)

    before do
      allow(Octokit).to receive(:user).with(username).and_return user_response
    end

    context "if there is one winner" do
      let(:repositories_1) {
        [
          Repository.new("repo_a", "Ruby"),
          Repository.new("repo_b", "Ruby"),
          Repository.new("repo_c", "Ruby"),
          Repository.new("repo_d", "Javascript"),
          Repository.new("repo_e", "Ruby"),
        ]
      }

      it "returns an array containting the user's favourite language" do
        expect(subject.favourite_languages).to match_array ["Ruby"]
      end
    end

    context "if there is a draw" do
      let(:repositories_1) {
        [
          Repository.new("repo_a", "Ruby"),
          Repository.new("repo_b", "Ruby"),
          Repository.new("repo_c", "Javascript"),
          Repository.new("repo_d", "Javascript"),
        ]
      }

      it "returns an array of the users favourite languages" do
        expect(subject.favourite_languages).to match_array ["Ruby", "Javascript"]
      end
    end

    context "if the available repos don't have language information" do
      let(:repositories_1) {
        [
          Repository.new("repo_a", nil),
          Repository.new("repo_b", nil),
        ]
      }

      it "returns an empty array" do
        expect(subject.favourite_languages).to eq []
      end
    end

    context "if there are no repositories" do
      it "returns an empty array" do
        expect(subject.favourite_languages).to eq []
      end
    end

    context "when there is more than one page" do
      let(:repositories_1) {
        [
          Repository.new("repo_a", "Ruby"),
          Repository.new("repo_b", "Ruby"),
        ]
      }
      let(:repositories_2) {
        [
          Repository.new("repo_a", "Javascript"),
          Repository.new("repo_b", "Javascript"),
        ]
      }
      let(:repositories_3) {
        [
          Repository.new("repo_a", "Java"),
          Repository.new("repo_b", "Java"),
        ]
      }

      it "loads repositories from each page" do
        expect(subject.favourite_languages).to match_array ["Ruby", "Javascript", "Java"]
      end

      context "A link relation is missing" do
        let(:repo_page_2_response)  { double("Repo  Page 2 Response", data: repositories_2, rels: {}) }

        it "will not load the next page" do
          expect(subject.favourite_languages).to match_array ["Ruby", "Javascript"]
        end
      end
    end
  end
end

