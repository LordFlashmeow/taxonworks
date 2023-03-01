module Queries
  module Person

    class Autocomplete < Query::Autocomplete

      include Queries::Concerns::AlternateValues
      include Queries::Concerns::Tags

      # @return [Array]
      # @param limit_to_role [String, Array] 
      #    any Role class, like `TaxonNameAuthor`, `SourceAuthor`, `SourceEditor`, `Collector`, etc.
      attr_accessor :role_type

      # any project == all roles
      # project_id - the target project in general

      # @param [Hash] args
      def initialize(string, **params)
        @role_type = params[:role_type]
        set_tags_params(params)
        set_alternate_value(params)
        super
      end

      def role_type
        [@role_type].flatten.compact.uniq
      end

      # @return [Arel::Nodes::Equatity]
      def role_match
        a = roles_table[:type].eq_any(role_type)
        a = a.and(roles_table[:project_id].eq_any(project_id)) if project_id.present?
        a
      end

      # @return [Arel::Nodes::Equatity]
      def role_project_match
        roles_table[:project_id].eq_any(project_id)
    end

      # @return [Scope]
      def autocomplete_exact_match
        base_query.where(
          table[:cached].eq(normalize_name).to_sql
        )
      end

      def autocomplete_exact_last_name_match
        base_query.where(
          table[:last_name].eq(query_string).to_sql
        )
      end

      # @return [Scope]
      def autocomplete_exact_inverted
        base_query.where(
          table[:cached].eq(invert_name).to_sql
        )
      end

      def autocomplete_alternate_values_last_name
        matching_alternate_value_on(:last_name)
      end

      def autocomplete_alternate_values_first_name
        matching_alternate_value_on(:first_name)
      end

      # TODO: Use bibtex parser!!
      # @param [String] string
      # @return [String]
      def normalize(string)
        n = string.strip.split(/\s*\,\s*/, 2).join(', ')
        n = 'nothing to match' unless n.include?(' ')
        n
      end

      # @return [String] simple name inversion
      #   given `Sarah Smith` return `Smith, Sarah`
      def invert_name
        normalize(
          query_string.split(/\s+/, 2).reverse.map(&:strip).join(', ')
        )
      end

      # @return [String]
      def normalize_name
        normalize(query_string)
      end

      # @return [Boolean]
      def roles_assigned?
        role_type.kind_of?(Array) && role_type.any?
      end

      # @return [Array]
      def autocomplete
        return [] if query_string.blank?
        queries = [
          [ autocomplete_exact_id, false ],
          [ autocomplete_exact_match.limit(5), true ],
          [ autocomplete_exact_inverted.limit(5), true ],
          [ autocomplete_identifier_cached_exact, false ],
          [ autocomplete_identifier_identifier_exact, false ],
          [ autocomplete_exact_last_name_match.limit(20), true ],
          [ autocomplete_alternate_values_last_name.limit(20), true ],
          [ autocomplete_alternate_values_first_name.limit(20), true ],
          [ autocomplete_ordered_wildcard_pieces_in_cached&.limit(5), true ],
          [ autocomplete_cached_wildcard_anywhere&.limit(20), true ], # in Queries::Query::Autocomplete
          [ autocomplete_cached, true ]
        ]

        queries.compact!

        updated_queries = []
        queries.each_with_index do |q, i|
          if q[0].nil?
            #do nothing
          elsif roles_assigned?
            a = q[0].joins(:roles).where(role_match.to_sql)


          elsif Current.project_id && q[1] # do not use extended query for identifiers
            a = q[0].left_outer_joins(:roles)
              .joins("LEFT OUTER JOIN sources ON roles.role_object_id = sources.id AND roles.role_object_type = 'Source'")
              .joins('LEFT OUTER JOIN project_sources ON sources.id = project_sources.source_id')
              .select("people.*, COUNT(roles.id) AS use_count, CASE WHEN MAX(roles.project_id) = #{Current.project_id} THEN MAX(roles.project_id) ELSE MAX(project_sources.project_id) END AS in_project_id")
              .where('roles.project_id = ? OR project_sources.project_id = ? OR (roles.project_id IS DISTINCT FROM ? AND project_sources.project_id IS DISTINCT FROM ?)', Current.project_id, Current.project_id, Current.project_id, Current.project_id)
              .group('people.id')
              .order('in_project_id, use_count DESC')
          end
          a ||= q[0]
          updated_queries[i] = a
        end
        
        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end
        result = result[0..19]
      end

      # @return [Arel::Table]
      def roles_table
        ::Role.arel_table
      end
    end
  end
end
