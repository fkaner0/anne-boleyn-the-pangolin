FROM sbtscala/scala-sbt:eclipse-temurin-21.0.5_11_1.10.7_3.3.4 AS build

WORKDIR /app

COPY project ./project
COPY build.sbt ./
COPY . .

RUN sbt clean assembly
RUN find target -name "*.jar" -type f | head -n 1 | xargs -I {} cp {} /app/app.jar

FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=build /app/app.jar /app/app.jar

ENV PORT=8080

EXPOSE 8080

CMD ["sh", "-c", "java -jar /app/app.jar"]