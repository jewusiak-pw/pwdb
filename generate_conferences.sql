DO $$
DECLARE
    v_start timestamptz;
    v_end timestamptz;
    v_city text;
    v_country text;
BEGIN
    CREATE TEMP TABLE if not exists tmp_cities (city text, country text);

    INSERT INTO tmp_cities (city, country) VALUES
        ('Warsaw', 'PL'), ('Krakow', 'PL'), ('Berlin', 'DE'), ('Munich', 'DE'), ('Hamburg', 'DE'),
        ('Paris', 'FR'), ('Lyon', 'FR'), ('Marseille', 'FR'), ('Madrid', 'ES'), ('Barcelona', 'ES'),
        ('Valencia', 'ES'), ('Rome', 'IT'), ('Milan', 'IT'), ('Naples', 'IT'), ('Amsterdam', 'NL'),
        ('Rotterdam', 'NL'), ('Lisbon', 'PT'), ('Porto', 'PT'), ('Prague', 'CZ'), ('Brno', 'CZ'),
        ('Vienna', 'AT'), ('Salzburg', 'AT'), ('Budapest', 'HU'), ('Szeged', 'HU'), ('London', 'GB'),
        ('Manchester', 'GB'), ('Birmingham', 'GB'), ('Dublin', 'IE'), ('Cork', 'IE'), ('Oslo', 'NO'),
        ('Bergen', 'NO'), ('Stockholm', 'SE'), ('Gothenburg', 'SE'), ('Copenhagen', 'DK'), ('Aarhus', 'DK'),
        ('Helsinki', 'FI'), ('Tampere', 'FI'), ('Zurich', 'CH'), ('Geneva', 'CH'), ('Brussels', 'BE'),
        ('Antwerp', 'BE'), ('Athens', 'GR'), ('Thessaloniki', 'GR'), ('Zagreb', 'HR'), ('Split', 'HR'),
        ('Sofia', 'BG'), ('Varna', 'BG'), ('Bucharest', 'RO'), ('Cluj-Napoca', 'RO'), ('Belgrade', 'RS'),
        ('Novi Sad', 'RS'), ('Istanbul', 'TR'), ('Ankara', 'TR'), ('Tallinn', 'EE'), ('Riga', 'LV'),
        ('Vilnius', 'LT'), ('Kyiv', 'UA'), ('Lviv', 'UA'), ('Minsk', 'BY'), ('Tbilisi', 'GE'),
        ('Yerevan', 'AM'), ('Baku', 'AZ'), ('New York', 'US'), ('Los Angeles', 'US'), ('Chicago', 'US'),
        ('Toronto', 'CA'), ('Vancouver', 'CA'), ('Montreal', 'CA'), ('Mexico City', 'MX'), ('Guadalajara', 'MX'),
        ('Santiago', 'CL'), ('Buenos Aires', 'AR'), ('Lima', 'PE'), ('Bogotá', 'CO'), ('São Paulo', 'BR'),
        ('Rio de Janeiro', 'BR'), ('Cape Town', 'ZA'), ('Johannesburg', 'ZA'), ('Cairo', 'EG'), ('Nairobi', 'KE'),
        ('Lagos', 'NG'), ('Accra', 'GH'), ('Dubai', 'AE'), ('Abu Dhabi', 'AE'), ('Riyadh', 'SA'),
        ('Doha', 'QA'), ('Tel Aviv', 'IL'), ('Jerusalem', 'IL'), ('Mumbai', 'IN'), ('Bangalore', 'IN'),
        ('Delhi', 'IN'), ('Singapore', 'SG'), ('Kuala Lumpur', 'MY'), ('Bangkok', 'TH'), ('Jakarta', 'ID'),
        ('Tokyo', 'JP'), ('Osaka', 'JP'), ('Seoul', 'KR'), ('Busan', 'KR'), ('Sydney', 'AU'),
        ('Melbourne', 'AU'), ('Auckland', 'NZ'), ('Wellington', 'NZ');

    FOR i IN 1..5000000 LOOP
        -- Losowy wybór miasta i kraju
        SELECT city, country INTO v_city, v_country
        FROM tmp_cities
        ORDER BY random()
        LIMIT 1;

        -- Losowy start w zakresie 2024–2026
        v_start := timestamp '2024-01-01 00:00:00'
                   + (random() * (extract(epoch FROM timestamp '2026-01-01 00:00:00' - timestamp '2024-01-01 00:00:00'))) * interval '1 second';

        -- Koniec: 1–5 dni po starcie
        v_end := v_start + (1 + random() * 4) * interval '1 day';

        INSERT INTO cfr.conferences (name, description, start_time, end_time, country, city, organiser_id)
        VALUES (
            'Conference ' || uuid_generate_v4(),
            'Description for conference ' || uuid_generate_v4(),
            v_start,
            v_end,
            v_country,
            v_city,
            5
        );
    END LOOP;
END$$;
