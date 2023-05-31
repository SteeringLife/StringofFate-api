# frozen_string_literal: true

module StringofFate
  # Policy to determine if account can view a card
  class CardPolicy
    # Scope of card policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_cards(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |proj|
            includes_collaborator?(proj, @current_account)
          end
        end
      end

      private

      def all_cards(account)
        account.owned_cards + account.recieved_cards
      end

      def includes_reciever?(card, account)
        card.recievers.include? account
      end
    end
  end
end
