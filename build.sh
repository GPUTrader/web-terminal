#!/bin/bash
# Build semantic-version
VERSION=1.0.2

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 590184001259.dkr.ecr.us-west-2.amazonaws.com

docker build --no-cache -t gputrader/webterm:${VERSION} .

# Tag semantic-version
docker tag gputrader/webterm:${VERSION} 590184001259.dkr.ecr.us-west-2.amazonaws.com/gputrader/webterm:${VERSION}

# Push semantic-version
docker push 590184001259.dkr.ecr.us-west-2.amazonaws.com/gputrader/webterm:${VERSION}

# Tag to latest-version
docker tag gputrader/webterm:${VERSION} 590184001259.dkr.ecr.us-west-2.amazonaws.com/gputrader/webterm:latest

# Push latest-version
docker push 590184001259.dkr.ecr.us-west-2.amazonaws.com/gputrader/webterm:latest
