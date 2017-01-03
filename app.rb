require "sinatra"
require "octokit"
require "./lib/github_user"
require './services/logger'

get "/" do
  erb :index
end

post "/favourite_language" do
  begin
    user = GithubUser.new(params[:username])
    presenter = ResultsPresenter.new(user.username, user.favourite_languages)
    result = presenter.result_string
  rescue GithubUser::NotFound => e
    FavLangLogger.log(:error, "Github user '#{params[:username]}'' could not be found.")
    result = "Could not find user '#{params[:username]}'. Please try again."
  rescue GithubUser::InvalidParams => e
    FavLangLogger.log(:error, e.message)
    result = e.message
  end

  erb :favourite_language, locals: {result: result}
end
