#!/usr/bin/python

# moderation logic
# select comment, return id and body text
# moderate body text
# if flagged is true
# update flag_count to send comment for moderation
#
# still to be done: if flagged is true hide comment?
#                   don't moderate comment which has been previously moderated?
#                   hide if flagged but flag if score is above threshold?
#                   auto hide if certain categories have scores
#                   make the above user configurable
#                   update notifications for moderator
#                   send email to user/moderator
#
#                   move openai key to config file
#                   move moderation to function
#                   provide option to use different moderation engines
#                   log moderation output to log file
#               
#                   automate running of script
#                   allow manual running of script from machine learning scripts folder

import psycopg2
import json
import os
import openai
from configparser import ConfigParser

from datetime import datetime

now = datetime.now()

configfile="moderate.ini"

path_dir =  "/home/deploy/consul/current/public/machine_learning/scripts/"

path_file = os.sep.join([path_dir, configfile])
print("start moderation"
print("path is ",path_file)

openai.api_key = "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"
 #   openai.api_key = os.getenv("OPENAI_API_KEY")


def config(filename=path_file, section='postgresql'):
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)

    # get section, default to postgresql
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section, filename))

    return db




def connect():
    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters
        params = config()

        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(**params)
                
        # create a cursor
        cur = conn.cursor()
        

        # close the communication with the PostgreSQL
        cur.close()
    except (Exception, , psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')



def update_flag(id, flags):
    """ update flag count based on the modrated flag """
    sql = """ UPDATE comments
                SET flags_count =  flags_count + %s
                WHERE id = %s"""
    conn = None
    updated_rows = 0
    try:
        # read database configuration
        params = config()
        # connect to the PostgreSQL database
        conn = psycopg2.connect(**params)
        # create a new cursor
        cur = conn.cursor()
        # execute the UPDATE  statement
        cur.execute(sql, (flags, id))
        # get the number of updated rows
        updated_rows = cur.rowcount
        # Commit the changes to the database
        conn.commit()

        print(updated_rows)
        # Close communication with the PostgreSQL database
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()

    return updated_rows

def hide_comment(id, ):
    """ update flag count based on the modrated flag """
    sql = """ UPDATE comments
                SET hidden_at =  LOCALTIMESTAMP
                WHERE id = %s"""
    conn = None
    updated_rows = 0
    try:
        # read database configuration
        params = config()
        # connect to the PostgreSQL database
        conn = psycopg2.connect(**params)
        # create a new cursor
        cur = conn.cursor()
        # execute the UPDATE  statement
        cur.execute(sql, (id,))
        # get the number of updated rows
        updated_rows = cur.rowcount
        # Commit the changes to the database
        conn.commit()

        print(updated_rows)
        # Close communication with the PostgreSQL database
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()

    return updated_rows




def get_records():

    # This program uses fetchall()
    # to query all the records from a table
     # read connection parameters
    params = config()
  
    # GET THE CONNECTION OBJECT
    conn = psycopg2.connect(**params)
  
# CREATE A CURSOR USING THE CONNECTION OBJECT

    curr = conn.cursor()
  
# EXECUTE THE SQL QUERY: get all comments newer than now - 12 hours
    query = "select comments.id,body,comments.hidden_at,flags_count,ancestry,commentable_type  from comments left join comment_translations on comments.id=comment_translations.id>
    #will want to refine this query not to select records previouslyrestored by moderator
    curr.execute(query)
    
  
# FETCH ALL THE ROWS FROM THE CURSOR
    data = curr.fetchall()
    rows=0  
# PRINT THE RECORDS
    for row in data:
        commentid=row[0]
        body=row[1]
        print("comment id",commentid,"body ",body)
        rows=rows+1  

# moderate

        response=openai.Moderation.create(
            input=body,
        )
        print("is this bodytext to be moderated")
      
        status = response["results"][0]["flagged"]
        print(status)
        
        if status :
#flagged status from moderation is true
            print(response["results"])
            flags = 10
            print("here and adding ", flags, " to ",commentid)
            update_flag(commentid, flags)
            hide_comment(commentid )
# need to add something here to notify moderator
# also need to make decisions about flag vs hide
        else:
        #loop through values andif above threshhold - flag comment
            print("no match in if statement")

# CLOSE THE CONNECTION
    conn.close()

    return rows





if __name__ == '__main__':

#    connect()
    get_records()
    # Update flag
    flags =  0
    
      
# print(output)
