module Connect
  class SubjectIdentifier
    attr_reader :client, :account

    def initialize(client, account)
      @client = client
      @account = account
    end

    def identifier
      if client.ppid?
        PairwisePseudonymousIdentifier.where(sector_identifier: client.sector_identifier, account: account).first_or_create.identifier
      else
        account.identifier
      end
    end
  end
end