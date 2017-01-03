require "./lib/results_presenter"

RSpec.describe ResultsPresenter do
  let(:favourite_languages) { [] }
  let(:username) { 'bob' }

  subject { ResultsPresenter.new(username, favourite_languages) }

  describe "#result_string" do
    context "when there is no favourite language" do
      it "returns a a helpful message" do
        expect(subject.result_string).to eq "#{username} does not appear to have any public repos with language information."
      end
    end

    context "when there is one favourite language" do
      let(:favourite_languages) { ["Ruby"] }

      it "returns a string with the favourite language" do
        expect(subject.result_string).to eq "#{username}'s favourite language is Ruby."
      end
    end

    context "when there is more than one favourite language" do
      let(:favourite_languages) { ["Ruby", "Javascript"] }

      it "returns a string with both favourite languages" do
        expect(subject.result_string).to eq "#{username}'s favourite languages are Ruby and Javascript."
      end

      context "when there is more than two favourite languages" do
        let(:favourite_languages) { ["Ruby", "Java", "C#"] }

        it "comma separates each language except for 'and' for the last two" do
          expect(subject.result_string).to eq "#{username}'s favourite languages are Ruby, Java and C#."
        end
      end
    end
  end
end
