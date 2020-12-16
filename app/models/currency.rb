class Currency < ApplicationRecord
  validates :hash_digest, presence: true

  after_commit :update_economy, :on => :update

  def update_economy
    #  check no of valid currencies i.e true
    valid_currencies = Currency.where(:validity => true).count
    current_difference = 200 - valid_currencies
    if current_difference > 0
      current_difference.times
      hashed = generate_hash.to_s
      single_currency = Currency.create(:hash_digest => hashed, :validity => true)
    else
      Currency.delete_all
    end
  end

  private
  # generating hash
  def generate_hash
    # taking time as random key
    key = Time.now.to_s + "#{rand(0..1000)}"
    # taking time of last month and random number as the data to be encoded
    data = Time.now.last_month.to_s + "#{rand(0..2000)}"
    # generating digest for sha256
    digest = OpenSSL::Digest.new('sha256')
    # converting the digest to hmax hex digest
    hashed = OpenSSL::HMAC.hexdigest(digest, key, data)
  end
end
