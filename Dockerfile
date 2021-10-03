#FROM node:lts-bullseye-slim as subspace_storage_builder
#RUN apt-get update && apt install -y git
#WORKDIR /
#RUN git clone https://github.com/clusterio/subspace_storage.git
#WORKDIR /subspace_storage
#RUN npm install \
#&& node build

FROM node:lts-bullseye-slim as clusterio_builder
WORKDIR /clusterio
#RUN mkdir -p factorio/bin/x64
#RUN wget -q -O factorio.tar.gz https://www.factorio.com/get-download/latest/headless/linux64 && tar -xf factorio.tar.gz && rm factorio.tar.gz
# Copy project files into the container
#COPY . .

#RUN npx lerna init

#RUN npm install 
#&& npx lerna bootstrap --hoist

#RUN npm init "@clusterio"


# Install plugins. This is intended as a reasonable default, enabling plugins to make for fun gameplay.
# If you want a different set of plugins, consider using this as the base image for your own.
RUN npm init -y

RUN npm install @clusterio/master ; mkdir sharedMods
COPY run-master.sh .
COPY startup.sh .
COPY mod_updater.py .

RUN echo '{\
  "dependencies": {\
    "@clusterio/master": "*"\
  }\
}' > package.json; pwd; cat /clusterio/package.json

RUN npm install @clusterio/plugin-subspace_storage ;npx clusteriomaster plugin add @clusterio/plugin-subspace_storage

RUN npm install @clusterio/plugin-inventory_sync; npx clusteriomaster plugin add @clusterio/plugin-inventory_sync

RUN npm install @clusterio/plugin-statistics_exporter; npx clusteriomaster plugin add @clusterio/plugin-statistics_exporter

RUN npm install @clusterio/plugin-research_sync; npx clusteriomaster plugin add @clusterio/plugin-research_sync

RUN npm install @clusterio/plugin-global_chat; npx clusteriomaster plugin add @clusterio/plugin-global_chat

RUN npx clusteriomaster config set master.http_port 12345

# Build submodules (web UI, libraries, plugins etc)
#RUN npx lerna run build
# Build Lua library mod
#RUN node packages/lib/build_mod --build --source-dir packages/slave/lua/clusterio_lib \
#&& mv dist/* sharedMods/ \
#&& mkdir temp \
#&& mkdir temp/test \
#&& cp sharedMods/ temp/test/ -r \
#&& ls sharedMods

# Remove node_modules
#RUN find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;

FROM frolvlad/alpine-glibc AS clusterio_final

RUN apk add --update bash nodejs npm

COPY --from=clusterio_builder /clusterio /clusterio
WORKDIR /clusterio

# Install runtime dependencies
RUN npm install --production
ENTRYPOINT ["/clusterio/startup.sh"]

