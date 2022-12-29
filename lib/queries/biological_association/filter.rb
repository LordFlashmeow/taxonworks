require 'queries/taxon_name/filter'
module Queries
  module BiologicalAssociation

    class Filter < Queries::Query
      include Queries::Concerns::Citations
      include Queries::Concerns::Notes
      include Queries::Concerns::Tags
      include Queries::Concerns::Users

      # TODO: can't handle []
      PARAMS = %w{
        any_global_id
        biological_association_id
        biological_associations_graph_id
        biological_relationship_id
        collecting_event_id
        collection_object_id
        geo_json
        geographic_area_id
        geographic_area_mode
        object_biological_property_id
        object_global_id
        object_taxon_name_id
        otu_id
        subject_biological_property_id
        subject_global_id
        subject_taxon_name_id
        taxon_name_id
        wkt
      }.freeze

      # TODO: Consider implementing passed queries
      # attr_accessor :taxon_name_query
      #
      # # @return [Symbol]
      # #   one of :any, :subject, :object
      # # @params [String, nil]
      # # If nil, then :any is returned
      # attr_accessor :taxon_name_query_target

      # @param collecting_event_id
      # @return Integer
      #   All BiologicalAssociations with CollectionObjects
      # linked to one or more CollectingEvent
      attr_accessor :collecting_event_id

      # @param otu_id
      # @return [Array]
      #   All BiologicalAssociations with OTU (only)
      #  matching subject OR object
      attr_accessor :otu_id

      # @param collection_object_id
      # @return [Array]
      #   All biological relationships with CollectionObject (only)
      #  matching subject OR object
      attr_accessor :collection_object_id

      # @param subject_taxon_name_id
      #   All BiologicalAssociations matching this name or
      # its children.
      # !! TaxonName must be valid!
      attr_accessor :subject_taxon_name_id

      # @param object_taxon_name_id
      #   All BiologicalAssociations matching this name or
      # its children
      # !! TaxonName must be valid!
      attr_accessor :object_taxon_name_id

      # @param taxon_name_id
      # @return [Array]
      #   All BiologicalAssociations matching these names or
      # their children
      # ??TODO: TaxonNames must be valid!
      attr_accessor :taxon_name_id

      # @param biological_associations_graph_id
      #   All BiologicalAssociations in any of the graphs above
      attr_accessor :biological_associations_graph_id

      # @return [Array]
      #   All BiologicalAssociations with subject having this property
      attr_accessor :subject_biological_property_id

      # @return [Array]
      #   All BiologicalAssociations with object having this property
      attr_accessor :object_biological_property_id

      # @return [Array]
      #   one or more biological association ids
      # @param biological_association_id [Array, Integer]
      attr_accessor :biological_association_id

      # @return [Array]
      #   one or more biological relationship ID
      # @param biological_relationship_id [Array, Integer]
      attr_accessor :biological_relationship_id

      # @return [Array]
      #   a biological relationship graph ID
      # @param biological_associations_graph_id [Array, Integer]
      attr_accessor :biological_associations_graph_id

      # @return [Array]
      attr_accessor :subject_global_id

      # @return [Array]
      attr_accessor :object_global_id

      # @return [Array]
      attr_accessor :any_global_id

      # See lib/queries/otu/filter.rb
      attr_accessor :wkt
      attr_accessor :geo_json
      attr_accessor :geographic_area_id

      attr_accessor :geographic_area_mode

      def initialize(params)
        # TODO: should be handled prior likely
        params.reject!{ |_k, v| v.nil? || v == '' }

        # TODO: perhaps remove
        taxon_name_params = ::Queries::TaxonName::Filter::PARAMS

        @taxon_name_query = ::Queries::TaxonName::Filter.new(
          params.select{|a,b| taxon_name_params.include?(a.to_s) }
        )

        # @taxon_name_query_target = params[:taxon_name_query_target]

        @subject_global_id = params[:subject_global_id]
        @object_global_id = params[:object_global_id]
        @any_global_id = params[:any_global_id]
        @biological_relationship_id = params[:biological_relationship_id]

        @biological_association_id = params[:biological_association_id]

        @subject_taxon_name_id = params[:subject_taxon_name_id]
        @object_taxon_name_id = params[:object_taxon_name_id]

        @taxon_name_id = params[:taxon_name_id]

        @otu_id = params[:otu_id]

        @collection_object_id = params[:collection_object_id]

        @biological_associations_graph_id = params[:biological_associations_graph_id]

        @wkt = params[:wkt]
        @geo_json = params[:geo_json]

        @collecting_event_id = params[:collecting_event_id]

        @object_biological_property_id = params[:object_biological_property_id]
        @subject_biological_property_id = params[:subject_biological_property_id]

        @geographic_area_id = params[:geographic_area_id]
        @geographic_area_mode = boolean_param(params, :geographic_area_mode)

        set_identifier(params)
        set_notes_params(params)
        set_tags_params(params)
        set_user_dates(params)
        set_citations_params(params)
      end

      # @return [Arel::Table]
      def table
        ::BiologicalAssociation.arel_table
      end

      def base_query
        ::BiologicalAssociation.select('biological_associations.*')
      end

      # def taxon_name_query_target
      #   @taxon_name_query_target.blank? ? :any : @taxon_name_query_target.to_sym
      # end

      def biological_association_id
        [@biological_association_id].flatten.compact
      end

      def object_biological_property_id
        [@object_biological_property_id].flatten.compact
      end

      def subject_biological_property_id
        [@subject_biological_property_id].flatten.compact
      end

      def collecting_event_id
        [@collecting_event_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      def collection_object_id
        [@collection_object_id].flatten.compact
      end

      def biological_relationship_id
        [@biological_relationship_id].flatten.compact
      end

      def biological_associations_graph_id
        [@biological_associations_graph_id].flatten.compact
      end

      def subject_global_id
        [@subject_global_id].flatten.compact
      end

      def object_global_id
        [@object_global_id].flatten.compact
      end

      def any_global_id
        [@any_global_id].flatten.compact
      end

      def geographic_area_id
        [@geographic_area_id].flatten.compact
      end

      # @return [ActiveRecord object, nil]
      # TODO: DRY
      def object_for(global_id)
        if o = GlobalID::Locator.locate(global_id)
          o
        else
          nil
        end
      end

      def subject_matches(object)
        table['biological_association_subject_id'].eq(object.id).and(
          table['biological_association_subject_type'].eq(object.class.base_class.name)
        )
      end

      def object_matches(object)
        table['biological_association_object_id'].eq(object.id).and(
          table['biological_association_object_type'].eq(object.class.base_class.name)
        )
      end

      def matching_global_id(target = :subject, global_ids = [])
        a = global_ids
        b = "#{target}_matches".to_sym

        q = send(b, object_for(a[0]))
        a[1..a.length].each do |i|
          q = q.or( send(b, object_for(i) ))
        end
        q
      end

      def geographic_area_id_facet 
        return nil if geographic_area_id.empty?

        a = nil

        case geographic_area_mode
        when nil, true # exact and spatial start the same
          a = ::GeographicArea.where(id: geographic_area_id)
        when false # descendants
          # TODO: check for Homonyms here?
          a = ::GeographicArea.descendants_of_any(geographic_area_id)
        end

        b = nil # from AssertedDistributions 
        c = nil # from CollectionObjects
        case geographic_area_mode
        when nil, false # exact, descendants

          gids = a.pluck(:id)

          otus = ::Queries::Otu::Filter.new(
            geographic_area_id: gids,
          ).all
        
          collection_objects = ::Queries::CollectionObject::Filter.new(
            geographic_area_id: gids,
          ).all

          d = ::BiologicalAssociation.where(biological_association_subject: [otus, collection_objects] )
          e = ::BiologicalAssociation.where(biological_association_object: [otus, collection_objects] )

          return ::BiologicalAssociation.from("((#{d.to_sql}) UNION (#{e.to_sql})) as biological_associations")
        when true # spatial
          i = ::GeographicItem.joins(:geographic_areas).where(geographic_areas: a)
          wkt_shape = ::GeographicItem.st_union(i).to_a.first['collection'].to_s
          return from_wkt(wkt_shape)
        end
      end

      # Not spatial
      def collecting_event_id_facet
        return nil if collecting_event_id.empty?

        collection_objects = ::Queries::CollectionObject::Filter.new(
          collecting_event_id: collecting_event_id
        ).all

        # if collection_objects.any?

        a = ::BiologicalAssociation.where(biological_association_subject: collection_objects )
        b = ::BiologicalAssociation.where(biological_association_object: collection_objects )

        # else
        # return nil
        # end

        ::BiologicalAssociation.from("((#{a.to_sql}) UNION (#{b.to_sql})) as biological_associations")
      end

      def wkt_facet
        return nil if wkt.nil?
        from_wkt(wkt)
      end

      # TODO: remove N + 1
      def from_wkt(wkt_shape)
        otus = ::Queries::Otu::Filter.new(wkt: wkt_shape).all.pluck(:id)
        collection_objects = ::Queries::CollectionObject::Filter.new(wkt: wkt_shape).all.pluck(:id)

        # b = ::BiologicalAssociation.where(biological_association_object: [otus, collection_objects] )

        a,b,c,d = nil, nil, nil, nil

        if !otus.empty?
          a = ::BiologicalAssociation.where(biological_association_subject_type: 'Otu', biological_association_subject_id: otus)
          c = ::BiologicalAssociation.where(biological_association_object_type: 'Otu', biological_association_object_id: otus)
        end

        if !collection_objects.empty?
          b = ::BiologicalAssociation.where(biological_association_subject_type: 'CollectionObject', biological_association_subject_id: collection_objects)
          d = ::BiologicalAssociation.where(biological_association_object_type: 'CollectionObject', biological_association_object_id: collection_objects)
        end

        q = [a,b,c,d].compact

        ::BiologicalAssociation.from('(' +  q.collect{|e| '(' + e.to_sql + ')' }.join(' UNION ') + ') as biological_associations')
      end

      def geo_json_facet
        return nil if geo_json.nil?
        otus = ::Queries::Otu::Filter.new(geo_json: geo_json).all
        collection_objects = ::Queries::CollectionObject::Filter.new(geo_json: geo_json).all

        a = ::BiologicalAssociation.where(biological_association_subject: [otus, collection_objects] )
        b = ::BiologicalAssociation.where(biological_association_object: [otus, collection_objects] )

        ::BiologicalAssociation.from("((#{a.to_sql}) UNION (#{b.to_sql})) as biological_associations").distinct
      end

      def object_biological_property_id_facet
        return nil if object_biological_property_id.empty?
        ::BiologicalAssociation.joins(:object_biological_relationship_types)
          .where(biological_relationship_types: {biological_property_id: object_biological_property_id })
      end

      def subject_biological_property_id_facet
        return nil if subject_biological_property_id.empty?
        ::BiologicalAssociation.joins(:subject_biological_relationship_types)
          .where(biological_relationship_types: {biological_property_id: subject_biological_property_id })
      end

      def biological_associations_graph_id_facet
        return nil if biological_associations_graph_id.empty?
        ::BiologicalAssociation.joins(:biological_associations_graphs).where(biological_associations_graphs: {id: biological_associations_graph_id})
      end


      def otu_params
      end

      def otu_facet
      end

      def collection_object_params
      end

      def collection_objects_facet
#        if !collection_object_params.empty?

#::Queries::CollectionObject::Filter.new(ancestor_id: id).all


      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?

        otus = []
        collection_objects = []

        # TODO: turn into joins
        taxon_name_id.each do |id|
          otus += ::Otu.descendant_of_taxon_name(id).all
          collection_objects += ::Queries::CollectionObject::Filter.new(ancestor_id: id).all
        end

        a = ::BiologicalAssociation.where(
          biological_association_subject: [otus, collection_objects].flatten
        )

        b = ::BiologicalAssociation.where(
          biological_association_object: [otus, collection_objects].flatten
        )

        ::BiologicalAssociation.from("((#{a.to_sql}) UNION (#{b.to_sql})) as biological_associations")
      end

      def otu_id_facet
        return nil if otu_id.empty?
        ::BiologicalAssociation.where(
          table[:biological_association_subject_id].eq_any(otu_id).and(table[:biological_association_subject_type].eq('Otu')
          .or(table[:biological_association_object_id].eq_any(otu_id).and(table[:biological_association_object_type].eq('Otu'))))
        )
      end

      def collection_object_id_facet
        return nil if collection_object_id.empty?
        ::BiologicalAssociation.where(
          table[:biological_association_subject_id].eq_any(collection_object_id).and(table[:biological_association_subject_type].eq('CollectionObject')
          .or( table[:biological_association_object_id].eq_any(collection_object_id).and(table[:biological_association_object_type].eq('CollectionObject'))))
        )
      end

      def subject_taxon_name_id_facet
        return nil if subject_taxon_name_id.blank?

        a = ::Otu.descendant_of_taxon_name(subject_taxon_name_id).all
        b = ::Queries::CollectionObject::Filter.new(ancestor_id: subject_taxon_name_id).all

        ::BiologicalAssociation.where(
          biological_association_subject: a + b, #  [a, b].flatten
        )
      end

      def object_taxon_name_id_facet
        return nil if object_taxon_name_id.blank?

        a = ::Otu.descendant_of_taxon_name(object_taxon_name_id).all
        b = ::Queries::CollectionObject::Filter.new(ancestor_id: object_taxon_name_id).all

        ::BiologicalAssociation.where(
          biological_association_object: [a, b].flatten
        )
      end

      def subject_global_id_facet
        return nil if subject_global_id.empty?
        matching_global_id(:subject, subject_global_id)
      end

      def object_global_id_facet
        return nil if object_global_id.empty?
        matching_global_id(:object, object_global_id)
      end

      def any_global_id_facet
        return nil if any_global_id.empty?
        a = matching_global_id(:subject, any_global_id)
        b = matching_global_id(:object, any_global_id)
        if a && b
          return a.or(b)
        else
          return a ? a : b
        end
      end

      # @return [Arel::Node, nil]
      def biological_relationship_id_facet
        return nil if biological_relationship_id.empty?
        table[:biological_relationship_id].eq_any(biological_relationship_id)
      end

      # @return [Arel::Node, nil]
      def biological_association_id_facet
        return nil if biological_association_id.empty?
        table[:id].eq_any(biological_association_id)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = base_and_clauses
        return nil if clauses.empty?
        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Array]
      def base_and_clauses
        clauses = []

        clauses += [
          biological_association_id_facet,
          subject_global_id_facet,
          object_global_id_facet,
          any_global_id_facet,
          biological_relationship_id_facet,
        ]
        clauses.compact!
        clauses
      end

      def base_merge_clauses
        clauses = []
        # clauses += taxon_name_merge_clauses + taxon_name_and_clauses

        clauses += [
          wkt_facet,
          geo_json_facet,
          object_biological_property_id_facet,
          subject_biological_property_id_facet,
          taxon_name_id_facet,
          collecting_event_id_facet,
          geographic_area_id_facet,
          otu_id_facet,
          collection_object_id_facet,
          subject_taxon_name_id_facet,
          object_taxon_name_id_facet,
          biological_associations_graph_id_facet,

          created_updated_facet, # See Queries::Concerns::Users

          keyword_id_facet,

          identifier_between_facet, # See Queries::Concerns::Identifiers
          identifier_facet,
          identifier_namespace_facet,
          match_identifiers_facet,

          note_text_facet,        # See Queries::Concerns::Notes
          notes_facet,            # See Queries::Concerns::Notes
        ]

        clauses.compact!
        clauses
      end

      # @return [ActiveRecord::Relation]
      def merge_clauses
        clauses = base_merge_clauses
        return nil if clauses.empty?
        a = clauses.shift
        
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses
        if a && b
          q = b.where(a).distinct
        elsif a
          q = :BiologicalAssociation.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::BiologicalAssociation.all
        end
      end

      # TaxonName - Query handling stubs
      #def taxon_name_query_facet

      #  # links to OTUs
      #  a = ...k?
      #  # Links to CollectionObjects
      #  b = ...

      #  # Union to BiologicalAssociations
      #end

      # TODO: wrong
      # def taxon_name_merge_clauses
      #   c = []

      #   # Convert base and clauses to merge clauses
      #   taxon_name_query.base_merge_clauses.each do |i|
      #     c.push ::BiologicalAssociation.joins(:taxon_name).merge( i )
      #   end
      #   c
      # end

      # def taxon_name_and_clauses
      #   c = []

      #   collection_object_base_query = nil
      #   otu_base_query = nil

      #   # Convert base and_clauses to merge clauses
      #   taxon_name_query.base_and_clauses.each do |i|
      #     if taxon_name_query_target == 'subject'
      #       case subject_type

      #       when 'collection_object'
      #         ::BiologicalAssociation
      #           .targeted_join(target: 'subject', target_class: ::CollectionObject)
      #           .merge(::Queries::CollectionObject::Filter.new(taxon_name_query:))
      #       when 'otu'
      #         ::BiologicalAssociation
      #           .targeted_join(target: 'subject', target_class: ::Otu)
      #           .merge(::Queries::CollectionObject::Filter.new(taxon_name_query:))
      #       else # both

      #       end

      #       c.push ::BiologicalAssociation.joins(:taxon_name).where( i )
      #     elsif taxon_name_query_target == 'object'

      #     else # it equals both

      #       byebug
      #     end

      #   end
      #   c
      # end

    end
  end
end
