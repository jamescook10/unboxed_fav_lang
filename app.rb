require "sinatra"
require "octokit"

module FavLang
  class App < Sinatra::Base
    get "/" do
      erb :index
    end

    post "/favourite_language" do
      user = Octokit.user params[:username]
      repos = user.rels[:repos].get.data
      languages = repos.map { |repo| repo.language }.compact
      counts = languages.each_with_object(Hash.new(0)) { |lang, counts| counts[lang] += 1 }
      top_language = counts.sort_by { |_, v| v }.reverse.first.first
      erb :favourite_language, locals: {user: user, language: top_language}
    end
  end
end
