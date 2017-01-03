require "sinatra"
require "octokit"
require "./lib/github_user"
require "./lib/results_presenter"
require './services/logger'

FavLangLogger.level = ENV['LOG_LEVEL'] || :info

get "/" do
  erb :index
end

post "/favourite_language" do
  begin
    user = GithubUser.new(params[:username])
    presenter = ResultsPresenter.new(user.username, user.favourite_languages)
    erb :"results/favourite_language", locals: { result: presenter.result_string, icons: presenter.icons }
  rescue GithubUser::NotFound => e
    FavLangLogger.log(:error, "Github user '#{params[:username]}'' could not be found.")
    erb :"results/user_not_found", locals: { username: params[:username] }
  rescue GithubUser::InvalidParams => e
    FavLangLogger.log(:error, e.message)
    erb :"results/error", locals: { message: e.message }
  rescue GithubUser::TooManyRequests => e
    FavLangLogger.log(:error, e.message)
    erb :"results/error", locals: { message: e.message }
  end
end
