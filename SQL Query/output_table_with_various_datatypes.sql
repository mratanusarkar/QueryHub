-- SELECT
--     1 AS id,
--     'example' AS word,
--     'This is a dummy sentence.' AS sentence,
--     ARRAY['a', 'b', 'c'] AS list,
--     '{"a": "Aa", "b": "Bb"}'::json AS object,
--     '<h1>Heading 1</h1>' AS html,
--     '<a href="https://www.google.com/">Google</a>' AS link,
--     '&#128993;' AS status

-- UNION ALL

-- SELECT
--     2,
--     'random',
--     'Another example sentence.',
--     ARRAY['d', 'e', 'f'],
--     '{"x": "Xx", "y": "Yy"}'::json,
--     '<h1>Heading 2</h1>',
--     '<a href="https://www.openai.com/">OpenAI</a>',
--     '&#9711;'

-- UNION ALL

-- SELECT
--     FLOOR(RANDOM() * 100)::int,
--     CHR(97 + FLOOR(RANDOM() * 26)::int),
--     'Randomly generated sentence.',
--     ARRAY[CHR(97 + FLOOR(RANDOM() * 26)::int), CHR(97 + FLOOR(RANDOM() * 26)::int), CHR(97 + FLOOR(RANDOM() * 26)::int)],
--     '{"key1": "value1", "key2": "value2"}'::json,
--     '<h1>Random Heading</h1>',
--     '<a href="https://www.wikipedia.org/">Wikipedia</a>',
--     '&#128308;'


SELECT
    (s.id % 10 + 1)::int AS id,
    CHR(97 + (s.id % 26)::int) AS word,
    'Sentence ' || s.id AS sentence,
    ARRAY[CHR(97 + ((s.id + 0) % 26)::int), CHR(97 + ((s.id + 1) % 26)::int), CHR(97 + ((s.id + 2) % 26)::int)] AS list,
    json_build_object('key', s.id, 'value', CHR(97 + (s.id % 26)::int)) AS object,
    '<h' || ((s.id % 5) + 1)::int || '>Heading ' || ((s.id % 5) + 1)::int || '</h' || ((s.id % 5) + 1)::int || '>' AS html,
    CASE
        WHEN s.id % 4 = 0 THEN '<a href="https://www.google.com">Google</a>'
        WHEN s.id % 4 = 1 THEN '<a href="https://www.wikipedia.org">Wikipedia</a>'
        WHEN s.id % 4 = 2 THEN '<a href="https://www.youtube.com">YouTube</a>'
        WHEN s.id % 4 = 3 THEN '<a href="https://www.openai.com/">OpenAI</a>'
        ELSE '<a href="https://www.twitter.com">Twitter</a>'
    END AS link,
    CASE
        WHEN s.id % 5 = 0 THEN '&#128993;'
        WHEN s.id % 5 = 1 THEN '&#9711;'
        WHEN s.id % 5 = 2 THEN '&#128308;'
        WHEN s.id % 5 = 3 THEN '&#128994;'
        ELSE '&#128993;'
    END AS status
FROM generate_series(1, 10) AS s(id);
