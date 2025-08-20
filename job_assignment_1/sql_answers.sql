--The names and the number of messages sent by each user 

select u.name, count(distict m.MessageId) messages_send
from messages m 
join users u 
on u.user_id = m.UserIDSender
group by 1;

--The total number of messages sent stratified by weekday
  select  FORMAT_DATE('%A',DateSent),  
    CASE
    WHEN FORMAT_DATE('%A', DateSent) = 'Monday' THEN 1
    WHEN FORMAT_DATE('%A', DateSent) = 'Tuesday' THEN 2
    WHEN FORMAT_DATE('%A', DateSent) = 'Wednesday' THEN 3
    WHEN FORMAT_DATE('%A', DateSent) = 'Thursday' THEN 4
    WHEN FORMAT_DATE('%A', DateSent) = 'Friday' THEN 5
    WHEN FORMAT_DATE('%A', DateSent) = 'Saturday' THEN 6
    WHEN FORMAT_DATE('%A', DateSent) = 'Sunday' THEN 7
  END
  ,count(distinct messageID) messages_sent
from messages
group by all
order by 2 desc

--The most recent message from each thread that has no response yet
-- Assumption: threads with no response contain of 1 message therefore the all the mesages from these threads order by time sent

with no_reponse as 
(
select distinct threadID, count(distinct messageID)
from messages
group by 1
having count(distinct messageID) = 1
)
select T.ThreadID,
  T.Subject,
  M.MessageContent,
  M.DateSent
from messages m 
join no_response n
on m.threadid = n.threadid
join threads t 
on m.threadid = t.threadid 
order by m.datesent;


-- For the conversation with the most messages: all user data and message contents ordered chronologically so one can follow the whole conversation 

WITH ThreadMessageCounts AS (
  -- Step 1: Find the total number of messages per thread.
  SELECT
    ThreadID,
    COUNT(MessageID) AS message_count
  FROM
    Messages
  GROUP BY
    ThreadID
),
MostMessagesThread AS (
  -- Step 2: Identify the ThreadID with the highest message count.
  SELECT
    ThreadID
  FROM
    ThreadMessageCounts
  ORDER BY
    message_count DESC
  LIMIT 1
)
-- Step 3: Retrieve all messages for that specific thread,
--         and join with User data.
SELECT
  T.ThreadID,
  T.Subject,
  M.DateSent,
  U.Name AS sender_name,
  M.MessageContent
FROM
  Messages AS M
INNER JOIN
  Threads AS T
  ON M.ThreadID = T.ThreadID
INNER JOIN
  User AS U
  ON M.UserIDSender = U.UserID
INNER JOIN
  MostMessagesThread AS MMT
  ON M.ThreadID = MMT.ThreadID
ORDER BY
  M.DateSent ASC; -- Step 4: Order chronologically

--For the conversation with the most messages: all user data and message contents ordered chronologically so one can follow the whole conversation 



--- Data wrangle for the dashbaord 
select *, cast(time_of_post as date) as date 
        ,dayname(cast(time_of_post as date)) as day
        ,dayofweek(cast(time_of_post as date)) day_of_week
        ,extract(hour from  cast(time_of_post as datetime)) as hour_of_day
        ,cast(number_of_impressions as numeric) / cast(number_of_tradies as numeric)   impression_per_tradie
        ,case when estimated_size = 'small' then 1 else 0 end as small
        ,case when estimated_size = 'medium' then 1 else 0 end as medium 
        , case when estimated_size = 'small' then 1 
               when estimated_size = 'medium' then 2
               else 3 end size_category
        ,round(latitude,0) AS lat_group
        ,round(longitude,0) AS lon_group
       
from Jobs
where number_of_impressions  is not null   
