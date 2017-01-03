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

  describe "#icons" do
    let(:favourite_languages) { ["Ruby", "Javascript", "Go"]}
    let(:icon_classes) {
      [
        "devicon-ruby-plain colored",
        "devicon-javascript-plain colored",
        "devicon-go-plain colored"
      ]
    }
    it "returns an array of CSS classes for displaying language icons" do
      expect(subject.icons).to match_array icon_classes
    end

    context "languages that don't have an icon" do
      let(:favourite_languages) { ["Haskell", "Nimrod"] }
      let(:unknown_languages) {
        [
          "unknown-language-icon",
          "unknown-language-icon"
        ]
      }

      it "presents a generic class" do
        expect(subject.icons).to match_array unknown_languages
      end
    end
  end
end
