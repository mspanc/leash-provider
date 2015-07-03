class Leash::Provider::UserInfoController < Leash::ProviderController
  def info
    render text: "missing_authorization_header", status: :unauthorized unless request.headers["Authorization"]
    render text: "missing_authorization_bearer", status: :unauthorized unless request.headers["Authorization"].starts_with? "Bearer "

    access_token_raw = request.headers["Authorization"].split(" ", 2).last

    render text: "invalid_access_token", status: :forbidden unless Leash::Provider::AccessToken.valid?(access_token_raw)

    access_token =  Leash::Provider::AccessToken.find_by_access_token(access_token_raw)
    owner = access_token.owner_instance

    if owner.respond_to? :for_leash_provider
      data = owner.for_leash_provider
    else
      data = owner
    end

    respond_to do |format|
      format.json do
        render json: data
      end
    end
  end
end