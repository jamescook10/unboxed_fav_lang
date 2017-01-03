class ResultsPresenter
  def initialize(username, favourite_languages)
    @favlangs = favourite_languages
    @username = username
  end

  def result_string
    if @favlangs.empty?
      "#{@username} does not appear to have any public repos with language information."
    elsif @favlangs.count == 1
      "#{@username}'s favourite language is #{@favlangs.first}."
    elsif @favlangs.count > 1
      build_multiple_languages_string
    end
  end

  private

  def build_multiple_languages_string
    if @favlangs.count > 2
      last_language = @favlangs.pop
      languages = @favlangs.join(", ")
      languages += " and #{last_language}"
    else
      languages = @favlangs.join(" and ")
    end

    "#{@username}'s favourite languages are #{languages}."
  end
end
