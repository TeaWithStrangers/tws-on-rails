class StaticController < ApplicationController
  def index
    use_new_styles

    @press = {
      'fast-company' => 'http://fastcompany.com',
      'forbes' => 'http://forbes.com',
      'huffington-post' => 'http://www.huffingtonpost.com/dr-shelley-prevost/creating-a-better-world-o_b_6061626.html',
      'tedxteen' => 'http://www.tedxteen.com/speakers-performers/tedxteen-2014-london/237-ankit-shah'
    }
    @cities = City.visible
    @cities_by_host  = Hash.new([]).merge(
      @cities.group_by { |x|
        if (x.fully_brewed? || x.warming_up?)
          :hosts
        else
          :no_hosts
        end
      })
  end

  def stories
  end

  def questions
  end

  def hosting
  end
end
