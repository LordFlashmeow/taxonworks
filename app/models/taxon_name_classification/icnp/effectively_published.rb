class TaxonNameClassification::Icnp::EffectivelyPublished < TaxonNameClassification::Icnp

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000081'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Icnp::NotEffectivelyPublished)
  end

  def self.assignable
    true
  end

  def sv_not_specific_classes
    soft_validations.add(:type, 'Please specify if the name is Validly or Invalidly Published')
  end
end
