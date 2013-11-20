# self.author & self.authors should match or one of them should be empty

class Source::Bibtex < Source

  before_validation :check_bibtex_type, :check_has_field
  #TODO: :update_authors_editor_if_changed? if: Proc.new { |a| a.password.blank? }

  has_many :author_roles, class_name: 'Role::SourceAuthor', as: :role_object
  has_many :authors, -> { order('roles.position ASC') }, through: :author_roles, source: :person
  has_many :editor_roles, class_name: 'Role::SourceEditor', as: :role_object
  has_many :editors, -> { order('roles.position ASC') }, through: :editor_roles, source: :person

  #region soft_validate calls
  soft_validate(:sv_has_authors)
  soft_validate(:sv_year_exists)
  soft_validate(:sv_has_a_date, set: :recommended_fields)
  soft_validate(:sv_contains_a_writer, set: :recommended_fields)
  soft_validate(:sv_has_title, set: :recommended_fields)
  soft_validate(:sv_has_year, set: :recommended_fields)
  soft_validate(:sv_is_article_missing_journal, set: :recommended_fields)
  soft_validate(:sv_has_URL, set: :recommended_fields) # probably should be sv_has_identifier instead of sv_has_URL
  soft_validate(:missing_required_bibtex_fields)
  #endregion

  #region constants
  # TW required fields (must have one of these fields filled in)
  TW_REQ_FIELDS = [
      :author,
      :editor,
      :booktitle,
      :title,
      :URL,
      :journal,
      :year,
      :stated_year
  ]
  #endregion

  def to_bibtex
    b = BibTeX::Entry.new(type: self.bibtex_type)
    ::BIBTEX_FIELDS.each do |f|
      if !(f == :bibtex_type) && (!self[f].blank?)
        b[f] = self.send(f)
      end
    end
    b
  end

  def valid_bibtex?
    self.to_bibtex.valid?
  end

  def self.new_from_bibtex(bibtex_entry)
    return false if !bibtex_entry.kind_of?(::BibTeX::Entry)
    s = Source::Bibtex.new(
        bibtex_type: bibtex_entry.type.to_s,
    )
    bibtex_entry.fields.each do |key, value|
      s[key] = value.to_s
    end
    s
  end

  def create_related_people
    return false if !self.valid? ||
        self.new_record? ||
        (self.author.blank? && self.editor.blank?) ||
        self.roles.count > 0

    # if !self.valid
    #   errors.add(:base, 'invalid source')
    #   return false
    # end
    #
    # if self.new_record?
    #   errors.add(:base, 'unsaved source')
    #   return false
    # end
    #
    # if (self.author.blank? && self.editor.blank?)
    #   errors.add(:base, 'no people to create')
    #   return false
    # end
    #
    # if self.roles.count > 0
    #   errors.add(:base, 'this source already has people attached to it via roles')
    # end

    bibtex = to_bibtex
    bibtex.parse_names
    bibtex.names.each do |a|
      p = Source::Bibtex.bibtex_author_to_person(a) #p is a TW person
      if bibtex.author
        self.authors << p if bibtex.author.include?(a)
      end
      if bibtex.editor
        self.editors << p if bibtex.editor.include?(a)
      end
    end
    return true
  end

  def self.bibtex_author_to_person(bibtex_author)
    return false if bibtex_author.class != BibTeX::Name
    Person.new(
        first_name: bibtex_author.first,
        prefix:     bibtex_author.prefix,
        last_name:  bibtex_author.last,
        suffix:     bibtex_author.suffix)
  end

  #region has_<attribute>? section
  def has_authors? # is there a bibtex author or author roles?

    # return true if !(self.author.to_s.strip.length == 0)
    return true if !(self.author.blank?)
    # author attribute is empty
    return false if self.new_record?
    # self exists in the db
    (self.authors.count > 0) ? (return true) : (return false)
  end

  def has_editors?
    return true if !(self.editor.blank?)
    # editor attribute is empty
    return false if self.new_record?
    # self exists in the db
    (self.editors.count > 0) ? (return true) : (return false)
  end

  def has_writer? # contains either an author or editor
    (has_authors?) || (has_editors?) ? true : false
  end

  def has_date? # is there a year or stated year?
    return true if !(self.year.blank?)
    return true if !(self.stated_year.blank?)
    return false
  end

  #TODO write has_note?
  #TODO write has_identifiers?

#endregion

  protected

  def check_bibtex_type # must have a valid bibtex_type
    errors.add(:bibtex_type, 'not a valid bibtex type') if !::VALID_BIBTEX_TYPES.include?(self.bibtex_type)
  end

  def check_has_field # must have at least one of the required fields (TW_REQ_FIELDS)
    valid = false
    TW_REQ_FIELDS.each do |i| # for each i in the required fields list
      if !self[i].blank?
        valid = true
        break
      end
    end
    # if i is not nil and not == "", it's validly_published
    #if (!self[i].nil?) && (self[i] != '')
    #  return true
    #end
    errors.add(:base, 'no core data provided') if !valid
                      # return false # none of the required fields have a value
  end

  #region Soft_validation_methods
  def sv_has_authors
    if !(has_authors?)
      soft_validations.add(:author, 'There is no author associated with this source.')
    end
  end

  def sv_contains_a_writer # neither author nor editor
    if !has_writer?
      soft_validations.add(:author, 'There is neither an author,nor editor associated with this source.')
      soft_validations.add(:editor, 'There is neither an author,nor editor associated with this source.')
    end
  end

  def sv_has_title
    if (self.title.blank?)
      soft_validations.add(:title, 'There is no title associated with this source.')
    end
  end

  def sv_has_a_date
    if (has_date?)
      soft_validations.add(:year, 'There is no year or stated year associated with this source.')
      soft_validations.add(:stated_year, 'There is no or stated year year associated with this source.')
    end
  end

  def sv_year_exists
    if !(year.blank?)
      soft_validations.add(:year, 'There is no year associated with this source.')
    end
  end

  def sv_missing_journal
    soft_validations.add(:bibtex_type, 'The source is missing a journal name.') if self.journal.blank?
  end

  def sv_is_article_missing_journal
    if (self.bibtex_type == 'article')
      if (self.journal.blank?)
        soft_validations.add(:bibtex_type, 'The article is missing a journal name.')
      end
    end
  end

  def sv_has_a_publisher
    if (self.publisher.blank?)
      soft_validations.add(:publisher, 'There is no publisher associated with this source.')
    end
  end

  def sv_has_booktitle
    if (self.booktitle.blank?)
      soft_validations.add(:booktitle, 'There is no book title associated with this source.')
    end
  end

  def sv_is_contained_has_chapter_or_pages
    if self.chapter.blank? && self.pages.blank?
      soft_validations.add(:chapter, 'There is neither a chapter nor pages with this source.')
      soft_validations.add(:pages, 'There is neither a chapter nor pages with this source.')
    end
  end

  def sv_has_school
    if (self.school.blank?)
      soft_validations.add(:school, 'There is no school associated with this thesis.')
    end
  end

  def sv_has_institution
    if (self.institution.blank?)
      soft_validations.add(:institution, 'There is not institution associated with this  tech report.')
    end
  end

  def sv_has_identifier
    #  TODO write linkage to identifiers (rather than local field save)
    # we have URL, ISBN, ISSN & LCCN as bibtex fields, but they are also identifiers.
    # do need to make the linkages to identifiers as well as save in the local field?
  end

  def sv_has_URL
    if (self.URL.blank?)
      soft_validations.add(:URL, 'There is no URL associated with this source.')
    end
  end

  def sv_has_note
    # TODO we may need to check of a note in the TW sense as well - has_note? above.
    if (self.note.blank?)
      soft_validations.add(:note, 'There is no note associated with this source.')
    end

  end

  def missing_required_bibtex_fields
    case self.bibtex_type
      when 'article' #:article       => [:author,:title,:journal,:year]
        sv_has_authors
        sv_has_title
        sv_is_article_missing_journal
        sv_year_exists
      when 'book' #:book          => [[:author,:editor],:title,:publisher,:year]
        sv_contains_a_writer
        sv_has_title
        sv_has_a_publisher
        sv_year_exists
      when 'booklet' #    :booklet       => [:title],
        sv_has_title
      when 'conference' #    :conference    => [:author,:title,:booktitle,:year],
        sv_has_authors
        sv_has_title
        sv_has_booktitle
        sv_year_exists
      when 'inbook' #    :inbook        => [[:author,:editor],:title,[:chapter,:pages],:publisher,:year],
        sv_contains_a_writer
        sv_has_title
        sv_is_contained_has_chapter_or_pages
        sv_has_a_publisher
        sv_year_exists
      when 'incollection' #    :incollection  => [:author,:title,:booktitle,:publisher,:year],
        sv_has_authors
        sv_has_title
        sv_has_booktitle
        sv_has_a_publisher
        sv_year_exists
      when 'inproceedings' #    :inproceedings => [:author,:title,:booktitle,:year],
        sv_has_authors
        sv_has_title
        sv_has_booktitle
        sv_year_exists
      when 'manual' #    :manual        => [:title],
        sv_has_title
      when 'mastersthesis' #    :mastersthesis => [:author,:title,:school,:year],
        sv_has_authors
        sv_has_title
        sv_has_school
        sv_year_exists
      #    :misc          => [],  (no required fields)
      when 'phdthesis' #    :phdthesis     => [:author,:title,:school,:year],
        sv_has_authors
        sv_has_title
        sv_has_school
        sv_year_exists
      when 'proceedings' #    :proceedings   => [:title,:year],
        sv_has_title
        sv_year_exists
      when 'techreport' #    :techreport    => [:author,:title,:institution,:year],
        sv_has_authors
        sv_has_title
        sv_has_institution
        sv_year_exists
      when 'unpublished' #    :unpublished   => [:author,:title,:note]
        sv_has_authors
        sv_has_title
        sv_has_note

    end

  end

  #endregion

end

