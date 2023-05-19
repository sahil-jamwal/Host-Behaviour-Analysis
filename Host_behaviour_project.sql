select * from hosts;
select * from listings;
select * from reviews;

-----------------------------------------------------------------------------------------------------
--a. Analyze different metrics to draw the distinction between Super Host and Other Hosts.

WITH Metrics AS (
    SELECT
        h.host_id,
        h.host_is_superhost,
        AVG(h.host_acceptance_rate) as avg_acceptance_rate,
        AVG(h.host_response_rate) as avg_response_rate,
        AVG(l.review_scores_rating) as avg_review_score,
        AVG(l.review_scores_cleanliness) as avg_cleanliness_score,
        AVG(l.review_scores_communication) as avg_communication_score,
        AVG(l.price) as avg_listing_price

    FROM
        Hosts h
        JOIN Listings l ON h.host_id = l.host_id
    GROUP BY
        h.host_id, h.host_is_superhost
)
SELECT
    host_is_superhost,
    AVG(avg_acceptance_rate) as avg_acceptance_rate,
    AVG(avg_response_rate) as avg_response_rate,
    AVG(avg_review_score) as avg_review_score,
    AVG(avg_cleanliness_score) as avg_cleanliness_score,
    AVG(avg_communication_score) as avg_communication_score,
    AVG(avg_listing_price) as avg_listing_price

FROM
    Metrics
GROUP BY
    host_is_superhost;

-----------------------------------------------------------------------------------------------------
--b. Analyze do Super Hosts tend to have large property types as compared to Other Hosts

WITH PropertySize AS (
    SELECT
        h.host_id,
        h.host_is_superhost,
        AVG(l.accommodates) as avg_accommodates,
        AVG(l.bedrooms) as avg_bedrooms,
        AVG(l.beds) as avg_beds
    FROM
        Hosts h
        JOIN Listings l ON h.host_id = l.host_id
    GROUP BY
        h.host_id, h.host_is_superhost
)
SELECT
    host_is_superhost,
    AVG(avg_accommodates) as avg_accommodates,
    AVG(avg_bedrooms) as avg_bedrooms,
    AVG(avg_beds) as avg_beds
FROM
    PropertySize
GROUP BY
    host_is_superhost;


-----------------------------------------------------------------------------------------------------
--c. Compare the top 5 neighborhoods with the highest average review scores for both Super Hosts and Other Hosts

WITH AvgReviewScores AS (
    SELECT
        h.host_is_superhost,
        l.neighbourhood_cleansed,
		ROUND(AVG(l.review_scores_rating),2) as avg_review_score
    FROM
        Listings l
        JOIN Hosts h ON l.host_id = h.host_id
    GROUP BY
        h.host_is_superhost, l.neighbourhood_cleansed
),
TopNeighborhoods AS (
    SELECT
        host_is_superhost,
        neighbourhood_cleansed,
        avg_review_score,
        ROW_NUMBER() OVER (PARTITION BY host_is_superhost ORDER BY avg_review_score DESC) as rank
    FROM
        AvgReviewScores
)
SELECT
    host_is_superhost,
    neighbourhood_cleansed,
    avg_review_score
FROM
    TopNeighborhoods
WHERE
    rank <= 5;


-----------------------------------------------------------------------------------------------------
--d. What is the maximum average price of listings based on the type of property and type of room?

SELECT property_type, room_type, AVG(price) as avg_price
FROM Listings
GROUP BY property_type, room_type
order by avg_price desc;


-----------------------------------------------------------------------------------------------------
--e. Analyze the average minimum and maximum nights for listings by Super Hosts and Other Hosts:

SELECT
    h.host_is_superhost,
    AVG(l.minimum_nights) as avg_min_nights,
    AVG(l.maximum_nights) as avg_max_nights
FROM
    Hosts h
    JOIN Listings l ON h.host_id = l.host_id
GROUP BY
    h.host_is_superhost;


-----------------------------------------------------------------------------------------------------
--f. What are the top rated locations by guests?

SELECT neighbourhood_cleansed, ROUND(AVG(review_scores_location),2)as avg_location_score
FROM Listings
GROUP BY neighbourhood_cleansed
ORDER BY avg_location_score DESC;


-----------------------------------------------------------------------------------------------------
--g. What are the most popular property types?

SELECT property_type, COUNT(*) as count
FROM Listings
GROUP BY property_type
ORDER BY count DESC;


-----------------------------------------------------------------------------------------------------
--h. Most common property types in each neighborhood.

WITH PropertyCount AS (
    SELECT
        neighbourhood_cleansed,
        property_type,
        COUNT(*) as count
    FROM
        Listings
    GROUP BY
        neighbourhood_cleansed, property_type
)
, RankedPropertyTypes AS (
    SELECT
        neighbourhood_cleansed,
        property_type,
        count,
        RANK() OVER (PARTITION BY neighbourhood_cleansed ORDER BY count DESC) as rank
    FROM
        PropertyCount
)
SELECT
    neighbourhood_cleansed,
    property_type,
    count
FROM
    RankedPropertyTypes
WHERE
    rank = 1;


-----------------------------------------------------------------------------------------------------
--i. Correlation between price and review scores.
SELECT
    price,
    AVG(review_scores_rating) as avg_review_score
FROM
    Listings
GROUP BY
    price
ORDER BY
    price desc;


-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
