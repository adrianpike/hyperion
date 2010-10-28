require 'benchmark'
require 'ruby-prof'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'hyperion'

class DefaultKey < Hyperion
	attr_accessor :content, :key
	hyperion_key :key
end

class NoKey < Hyperion
	attr_accessor :content
end

class IndexedObject < Hyperion
	attr_accessor :content, :other_content, :key
	
	hyperion_key :key
	hyperion_index :other_content
	hyperion_index [:content, :other_content]
end

[100,1000,10000,100000].each {|n|
	puts "===== #{n} ====="
	puts "#{n} inserts:"
	bm = Benchmark.measure {
		n.times do |k|
			f = DefaultKey.new({
				:key => k,
				:content => "Benchmarking!"
			})
			f.save
		end
	}
	p bm

	puts "#{n} fetches:"
	bm = Benchmark.measure {
		n.times do |k|
			f = DefaultKey.find(k)
		end
	}
	p bm

	puts "#{n} inserts w/autoincrement:"
	bm = Benchmark.measure {
		n.times do |k|
			f = DefaultKey.new({
				:content => "Benchmarking!"
			})
			f.save
		end
	}
	p bm

	puts "#{n} inserts with indexes and autoincrement:"
	bm = Benchmark.measure {
		n.times do |k|
			f = IndexedObject.new({
				:content => "Benchmarking!",
				:other_content => k
			})
			f.save
		end
	}
	p bm

	puts "#{n} fetches on a single index:"
	bm = Benchmark.measure {
		n.times do |k|
			f = IndexedObject.find({
				:other_content => k
			})
		end
	}
	p bm

	puts "#{n} fetches on a complex index:"
	bm = Benchmark.measure {
		n.times do |k|
			f = IndexedObject.find({
				:content => 'Benchmarking!',
				:other_content => k
			})
		end
	}
	p bm


	puts "#{n} indexless updates:"
	bm = Benchmark.measure {
		n.times do |k|
			f = DefaultKey.find(k)
			f.content = 'Second time around'
			f.save
		end
	}
	p bm
}