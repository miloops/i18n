require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'i18n/gettext'

class I18nGettextBackendTest < Test::Unit::TestCase
  def setup
    I18n.locale = :en
    I18n.load_path = [File.dirname(__FILE__) + '/../locale/de.po']
    I18n.backend = I18n::Backend::Gettext.new
  end
  
  def teardown
    I18n.load_path = nil
    I18n.backend = nil
  end

  def test_backend_loads_po_file
    I18n.backend.send(:init_translations)
    assert I18n.backend.send(:translations)[:de][:"Axis\001Axis"]
  end
  
  def test_looks_up_translation
    I18n.locale = :de
    assert_equal 'Auto', _('car')
  end
  
  def test_pluralizes_entry
    I18n.locale = :de
    assert_equal 'Achsen', ngettext('Axis', 'Axis', 2)
  end
end