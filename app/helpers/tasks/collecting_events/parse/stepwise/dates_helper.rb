module Tasks::CollectingEvents::Parse::Stepwise::DatesHelper

  def parse_label(label)
    retval = Utilities::Dates.hunt_wrapper(label)
    retval
  end

  def make_dates_method_headers
    list = Utilities::Dates::REGEXP_DATES
    selector_row = ""
    list.keys.each_with_index {|kee, dex|
      selector_row += content_tag(:th, Utilities::Dates::REGEXP_DATES[kee][:hdr],
                                  data: {help: Utilities::Dates::REGEXP_DATES[kee][:hlp]})
    }
    selector_row.html_safe
  end


  # @param [Array] must be array of symbols from Utilities::Geo::REGEXP_COORD
  def make_dates_selected_method_boxes(filters = Utilities::Dates::REGEXP_DATES.keys)
    list = Utilities::Dates::REGEXP_DATES
    box_row = ""
    list.keys.each { |kee|
      checked = filters.include?(kee)
      box_row += content_tag(:td, check_box_tag("filters[]", kee.to_s, checked), align: 'center')
    }
    box_row.html_safe
  end


  def make_dates_rows(label, filters)
    return nil if label.nil?
    tests = Utilities::Dates.hunt_dates(label, filters)
    tests.keys.collect.with_index do |kee, dex|
      trial = tests[kee]
      method = trial.delete(:method) # extract the method from the trial and save it
      next if trial.blank? # if this leaves the trial empty, skip
      # ActionController::Redirecting.redirect_to dates_index_task_path(collecting_event_id: next_collecting_event_id,
      #                                                                 filters: parse_filters(params))
      verbatim_date_piece = make_verbatim_date_piece(label, trial[:piece])
      content_tag(:tr, class: :extract_row) do
        content_tag(:td, method, align: 'center', class: :method_value) +
            # content_tag(:td, kee == method ? '' : kee) +
            # content_tag(:td, trial[:piece], class: :piece_value, align: 'center') +
            content_tag(:td, verbatim_date_piece, class: :piece_value, align: 'center') +
            content_tag(:td, trial[:start_date], class: :start_date_value, align: 'center') +
            content_tag(:td, trial[:end_date], class: :end_date_value, align: 'center') +
            content_tag(:td, radio_button_tag('select', dex, false, class: :select_dates), align: 'center')
      end
    end.join.html_safe
    # tests.keys.each { |kee|
    # next if tests[kee]
    # }
    # @matching_items = {@collecting_event.id.to_s => tests.first[:piece]}
  end

  def make_verbatim_date_piece(label, pieces)
    left = label.index(pieces[0])
    right = left + pieces[0].length - 1 #
    unless pieces[1].blank?
      right = label.index(pieces[1]) + pieces[1].length - 1
    end
    label[left..right]
  end

  # @param [String] pieces is either piece, or lat, long
  # @param [Scope] collection is a scope of CollectingEvent
  # "identical matches" result table
  def make_dates_matching_table(*pieces, collection)
    columns = ['CEID', 'Match', 'Verbatim Date', 'Select']

    thead = content_tag(:thead) do
      content_tag(:tr) do
        columns.collect { |column| concat content_tag(:th, column) }.join.html_safe
      end
    end

    tbody = content_tag (:tbody) do
      collection.collect { |item|
        content_tag (:tr) do
          item_data = ''
          no_verbatim_date = false
          columns.collect.with_index { |column, dex|
            case dex
              when 0 #'CEID'
                item_data = link_to(item.id, item)
              when 1 #'Match'
                item_data = content_tag(:vl, pieces.join(' '), data: {help: item.verbatim_label})
              when 2 #'Verbatim Date'
                item_data = item.verbatim_date
                no_verbatim_date = !item.verbatim_date.blank?
              when 3 #'Select'
                # check_box_tag(name, value = "1", checked = false, options = {}) public
                options_for = {disabled: no_verbatim_date}
                options_for[:class] = 'selectable_select' unless no_verbatim_date
                item_data = check_box_tag('selected[]', item.id, false, options_for)
            end
            concat content_tag(:td, item_data, align: 'center')
          }.to_s.html_safe
          # item.attributes.collect { |column|
          #   concat content_tag(:td, item.attributes[column])
          # }.to_s.html_safe
        end
      }.join().html_safe
    end

    content_tag(:table, thead.concat(tbody), {id: 'matching_table', border: '1'}).html_safe
  end

  def test_start_date # what is "test" about this?
    @collecting_event.verbatim_date unless @collecting_event.nil?
  end

  def test_end_date
    @collecting_event.verbatim_date unless @collecting_event.nil?
  end

  def show_ce_vl(collecting_event)
    message = 'No collecting event available.'
    unless collecting_event.nil?
      message = collecting_event.verbatim_label
    end
    collecting_event_label_tag(message)
  end

  def parse_date_skip(current_collecting_event_id, filters)
    # TODO: Now this has to be bound to next hit
    # filters = Utilities::Geo::REGEXP_COORD.keys
    next_id = Queries::CollectingEventDatesExtractorQuery.new(
        collecting_event_id: current_collecting_event_id,
        filters: filters).all.with_project_id(sessions_current_project_id).first.try(:id)
    if next_id
      button_tag('Skip to next record', value: 'skip', id: 'skip')
    else
      content_tag(:span, 'no more matches')
    end + button_tag('Re-evaluate', value: 're_eval', id: 're_eval')
  end

  def scan_c_e
    pile = Queries::CollectingEventDatesExtractorQuery.new(
        collecting_event_id: 0,
        filters: DEFAULT_SQL_REGEXS).all.with_project_id(sessions_current_project_id).order(:id)
    pile.each { |c_e|
      trials = Utilities::Dates.hunt_dates_full(c_e.verbatim_label)
      puts(c_e.id)
    }
    pile
  end

end
