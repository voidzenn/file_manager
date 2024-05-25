# Use the official Ruby image as the base
FROM ruby:3.0.4

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

# Install the gem dependencies
RUN bundle install

# Copy the rest of the application
COPY . /app

# Copy the .env file into the container
COPY .env /app/.env

# Load environment variables using dotenv
RUN echo "source /app/.env" >> /root/.bashrc

# Copy entrypoint script
COPY entrypoint.sh /usr/bin/

# Ensure the entrypoint script is executable
RUN chmod +x /usr/bin/entrypoint.sh

# Precompile assets (if needed)
RUN bundle exec rake assets:precompile

# Expose port 3000 to the Docker host
EXPOSE 3000

# Set the entrypoint
ENTRYPOINT ["entrypoint.sh"]

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
