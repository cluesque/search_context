require 'search_context'
class Name <ActiveRecord::Base
  include SearchContext::Methods
  attr_accessible :count, :term
  
  # override the search_config if you are using some other search configuration
  def self.search_config
    "names_search_config"
  end
  # central place for queries using this search context, if it makes sense to share the search queries amoung multiple duck-typed models.
  # for example, BottleSource, Bottle, Wine all use similar vocabulary and search configuration. and queries
  module Query extend ActiveSupport::Concern
    included do
      # this example demostrates synonyms and stop words implemented via the aliases table, which you have to figure out
      # how to populate on your own
      scope :similar_to, lambda {|term1|
       similar_terms = Name.similar_terms(term1).join(' | ')
       where("ts_rewrite(to_tsquery(?,?),'select original,substitution from name_aliases WHERE to_tsquery('?','?') @>original') @@ names_vector",
           Name.search_config, similar_terms,
           Name.search_config, similar_terms)
      }
    end
  end
end