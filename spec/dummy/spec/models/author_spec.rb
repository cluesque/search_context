require 'spec_helper'

describe Author do
  before do
    Name.delete_all
  end
  let(:record) {Author.new(:first_name=>'Joe', :last_name=>'Saint John')}
  it 'should calculate_names' do
    record.calculate_names.should == ['joe','saint','john']
  end
  it 'should save search terms' do
    expect{record.save!}.to change{Name.count}.by(3)
  end
  it 'should delete search terms' do
    record.save!
    expect{record.destroy}.to change{Name.count}.by(-3)
  end
  it 'should update search terms' do
    record.save!
    record.first_name = 'Mac'
    record.save!
    Name.where(:name=>'mac').should_not be_empty
    Name.where(:name=>'joe').should be_empty
  end
  it 'should update search terms for a find' do
    record.save!
    tmp = Author.find(record.id)
    tmp.first_name = 'Mac'
    tmp.save!
    Name.where(:name=>'mac').should_not be_empty
    Name.where(:name=>'joe').should be_empty
  end
  describe 'finding stuff - basic' do
    before do
      record.save!
    end
    it 'understand similar_to' do
      Author.similar_to('joe').should_not be_empty
    end
    it 'understand similar_to for slight differences' do
      Author.similar_to('joee').should_not be_empty
    end
    it 'scopes compose'do
      Author.where('created_at > ?',1.day.ago).similar_to('joe').should_not be_empty
    end
  end
  describe 'aliases' do
    before do
      NameAlias.delete_all
      record.save!
      {'joseph'=>'joe','mr'=>''}.each_pair do |k,v|
        NameAlias.create!(:original=>k,:substitution=>v)
      end
    end
    it 'synonyms' do
      Author.similar_to('joseph').should_not be_empty
    end
    it 'stop words' do
      Author.similar_to('mr Mr joe Saint John').should_not be_empty
    end
  end
end
