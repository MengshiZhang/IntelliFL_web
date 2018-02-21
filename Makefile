
serve:
	bundle exec jekyll serve --watch --trace

setup:
	apt install ruby-dev libffi-dev
	gem install bundler
	bundle install