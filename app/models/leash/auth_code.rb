class Leash::AuthCode < Ohm::Model
  MAX_ASSIGN_TRIES = 20

  attribute :app_name
  attribute :auth_code
  attribute :owner
  attribute :created_at

  index :owner
  index :auth_code
  unique :auth_code


  def self.assign!(app_name, owner)
    tries = 0
    auth_code = nil

    loop do
      begin
        auth_code = SecureRandom.hex(24)
        timestamp = Time.now.to_i
        self.create app_name: app_name, owner: owner, auth_code: auth_code, created_at: timestamp
        break
      
      rescue Ohm::UniqueIndexViolation => e
        tries += 1

        fail if tries > MAX_ASSIGN_TRIES
      end
    end

    auth_code
  end


  def self.valid?(auth_code)
    self.find(auth_code: auth_code).size != 0
  end


  def self.find_by_auth_code(auth_code)
    self.find(auth_code: auth_code).first
  end
end