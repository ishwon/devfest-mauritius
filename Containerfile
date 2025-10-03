# ---------- Tailwind build stage ----------
FROM node:20-alpine AS ui
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY tailwind.config.js postcss.config.js ./ 
COPY assets ./assets
# we need templates (content scanning) to ensure JIT picks classes
COPY templates ./templates
RUN npx tailwindcss -i ./assets/styles.css -o ./public/assets/app.css --minify

# ---------- Go build stage ----------
FROM golang:1.24-alpine AS build
WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
# copy the CSS built by the UI stage into the same tree so it's available at runtime
COPY --from=ui /app/public/assets ./public/assets
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /bin/app main.go

# ---------- Minimal runtime ----------
FROM registry.suse.com/bci/bci-base:15.7
WORKDIR /app
COPY --from=build /bin/app /app/app
COPY --from=build /src/templates /app/templates
COPY --from=build /src/public /app/public
ENV PORT=8080 GIN_MODE=release
EXPOSE 8080
USER 65532:65532
ENTRYPOINT ["/app/app"]
