#!/bin/sh

#####
#  Automatically add your checkin comment to a JIRA issue
#
#    usage: [projectAbbr]-[issueNumber]:
#
#    example: git commit -m "PROJ-272: Code changes relating to PROJ-272"
#
#    installation: add this to your hooks at: ${repo}/hooks/post-receive
#####

user='USERNAME'
pass='PASSWORD'
host='http://atlassian.net'

comment_path='rest/api/2/issue'
comment_action='comment'

delimiter='~!~'

while read oldrev newrev ref
do
		branch=`echo $ref | cut -d/ -f3`

		hashval=`git log $branch --pretty=format:"%H" -1 HEAD`
		author=`git log $branch --pretty=format:"%an" -1 HEAD`
		message=`git log $branch --pretty=format:"%s" -1 HEAD`

		# get issue number
		issue=`echo "$message" | cut -d ':' -f 1`
		if [ ${#issue} -eq ${#message} ]; then
				echo "no JIRA project provided"
		else
				if echo "$issue" | grep '[a-zA-Z]*-[0-9]'; then
						description=`echo "$message" | cut -d ':' -f 2`
						bodytext="$author ($hashval): \\\n\\\n $description"
						json=`echo {\"body\":\"${bodytext}\"}`
						jiraUrl=$host/$comment_path/$issue/$comment_action

						#echo "curl -D- -u $user:$pass -X POST -d '${json}' -H 'Content-Type: application/json' $jiraUrl"
						echo "Adding commit to JIRA issue $issue"
						response=$(curl -D- --silent --output /dev/null -u $user:$pass -X POST -d "${json}" -H 'Content-Type: application/json' $jiraUrl)

				else
						echo "No regex match on $issue for JIRA project"
				fi
		fi	
done
