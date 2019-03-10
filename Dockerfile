FROM reasno/countminsketch:latest as countminsketch
FROM reasno/redis-tdigest:latest as tdigest
FROM reasno/topk:latest as topk
FROM redislabs/rebloom:latest as rebloom

FROM redis:5 as redis
ENV LIBDIR /usr/lib/redis/modules
WORKDIR /data
RUN set -ex;\
    apt-get update;\
    apt-get install -y --no-install-recommends libgomp1;\
    mkdir -p ${LIBDIR};
COPY --from=countminsketch ${LIBDIR}/countminsketch.so ${LIBDIR}
COPY --from=tdigest ${LIBDIR}/tdigest.so ${LIBDIR}
COPY --from=topk ${LIBDIR}/topk.so ${LIBDIR}
COPY --from=rebloom ${LIBDIR}/rebloom.so ${LIBDIR}

ENTRYPOINT ["redis-server"]
CMD ["--loadmodule", "/usr/lib/redis/modules/countminsketch.so", \
    "--loadmodule", "/usr/lib/redis/modules/tdigest.so", \
    "--loadmodule", "/usr/lib/redis/modules/topk.so", \
    "--loadmodule", "/usr/lib/redis/modules/rebloom.so"]