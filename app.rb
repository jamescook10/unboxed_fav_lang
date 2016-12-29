require "sinatra"

class FavLang < Sinatra::Base
  get "/" do
    erb :index
  end

  post "/favourite_language" do
    @username = params[:username]
    erb :favourite_language
  end
end
