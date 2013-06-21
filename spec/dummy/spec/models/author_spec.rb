require 'spec_helper'

describe Author do
  before do
    SearchTerm.delete_all
  end
  let(:record) {Author.new(:first_name=>'Joe', :last_name=>'Saint John')}
  it 'should calculate_search_terms' do
    record.calculate_search_terms.should == ['joe','saint','john']
  end
  it 'should save search terms' do
    expect{record.save!}.to change{SearchTerm.count}.by(3)
  end
  it 'should delete search terms' do
    record.save!
    expect{record.destroy}.to change{SearchTerm.count}.by(-3)
  end
  it 'should update search terms' do
    record.save!
    record.first_name = 'Mac'
    record.save!
    SearchTerm.where(:term=>'mac').should_not be_empty
    SearchTerm.where(:term=>'joe').should be_empty
  end
  it 'should update search terms for a find' do
    record.save!
    tmp = Author.find(record.id)
    tmp.first_name = 'Mac'
    tmp.save!
    SearchTerm.where(:term=>'mac').should_not be_empty
    SearchTerm.where(:term=>'joe').should be_empty
  end
  describe 'finding stuff - basic' do
    before do
      record.save!
    end
    it 'understand similar_to' do
      Author.similar_to('joe').should_not be_empty
    end
    it 'scopes compose'do
      Author.where('created_at > ?',1.day.ago).similar_to('joe').should_not be_empty
    end
  end
end
