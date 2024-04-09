#!/bin/bash                                                                                   #
# SELFISH ROUND ROBIN ALGORITHM:                                                              #
# It prioritizes processes with prolonged or extended execution timeSlices and high priority, #
# ensuring they obtain or receive the required Central Processing Unit(CPU) time.             # 
# The selfish round-robin algorithm is designed to optimize the implementation beyond         #
# the standard round-robin method.                                                            #
#                                                                                             #
#                                                                                             #
# Name: Joshua Addai-Marnu                                                                    #
# Date: 13/12/2023                                                                            #
# Student_ID: 19548571                                                                        #
#                                                                                             #
###############################################################################################


incValAcceptedQ=1   
incValNewQ=2        
quanta=1            
directOutput=       
outputToFile=       
processesCompleted=0  
time=0
paddingSpace=10
timeConsumed=0
progArguments=($*)
lengthOfArguments=$#


declare -a nameOfProcesses=()
declare -a serviceTimeProcesses=()
declare -a arrivalTimeProcesses=()

declare -a nameOfNewQ=()
declare -a serviceTimeNewQ=()
declare -a priorityNewQ=()
declare -a statusNewQ=()

declare -a nameOfAcceptedQ=()
declare -a serviceTimeAcceptedQ=()
declare -a priorityAcceptedQ=()
declare -a statusAcceptedQ=()


adjustNumSpaces() {
    local numberOfSpaces="$1"
    local time="$2"

    if [ "${#time}" -ge 2 ]; then
        numberOfSpaces=$((numberOfSpaces - ${#time} + 1))
    fi

    echo "$numberOfSpaces"
}

verifyQuanta() {
    if [ "${serviceTimeAcceptedQ[0]}" -gt 0 ]; then
        ((timeConsumed += 1))
    else
        timeConsumed=$quanta
    fi
}


outputResultDestination() {
    local directOutput="$1"
    local content="$2"
    local outputToFile="$3"
    local addParameter="$4"

    if [[ "$directOutput" == "file" || "$directOutput" == "both" ]]; then
        # Make sure the directory structure exist.
        mkdir -p "$(dirname "$outputToFile")"
        # Check if added parameter is specified
        if [ "$addParameter" == "addParameter" ]; then
            echo "$content" >> "$outputToFile"
        else
            echo "$content" > "$outputToFile"
        fi
    fi

    if [[ "$directOutput" == "stdout" || "$directOutput" == "both" ]]; then
        echo "$content"
    fi
}


createHeader() {
    local name="$1"
    local numberOfSpaces="$2"
    echo -n "$name"
    
    for ((i=0; i<numberOfSpaces; i++)); do
        echo -n " "
    done
}

displayErrorMsgAndExit() {
    local errorMsg="$1"
    echo "Error:  $errorMsg"
    exit 1
}


if ! [ -e "${progArguments[0]}" ]
then
    displayErrorMsgAndExit "Input error. The file path ${progArguments[0]} does not exist."
fi

if [ $lengthOfArguments -lt 3 ]
then  
    displayErrorMsgAndExit "Sorry🙁, three or four arguments are required."
elif [ $lengthOfArguments -eq 4 ]
then
    if [[ ${progArguments[3]} =~ ^[0-9]+$ ]]
    then
        quanta=${progArguments[3]}
    else
        displayErrorMsgAndExit "Sorry🙁, enter the correct value (The quanta value has 
        to be an integer)."
    fi
fi

if ! [[ ${progArguments[1]} =~ ^[0-9]+$ ]] || ! [[ ${progArguments[2]} =~ ^[0-9]+$ ]] 
    then 
        displayErrorMsgAndExit "Ooops🤔: Argument 2 and 3 values should be integers"
elif [[ ${progArguments[1]} -lt ${progArguments[2]} ]]
    then 
        displayErrorMsgAndExit "Ooops🤔: The incremental value of the of 'Argument 2(New Queue)' 
        should be greater than the incremental value of 'argument 3(Accepted Queue)'"
else
    incValNewQ=${progArguments[1]}
    incValAcceptedQ=${progArguments[2]}
fi



echo "******************************************"
echo "THIS IS THE SELFISH ROUND ROBIN ALGORITHM"
echo "******************************************"
echo


while true;
do
    echo -e "Which of the following options do you want the output of the results to be displayed?  [OPTIONS: STDOUT or FILE or BOTH]"
    read userFeedback

    directOutput=$(echo "$userFeedback" | tr '[:upper:]' '[:lower:]')

    if [[ "$directOutput" == "stdout" || "$directOutput" == "file" || "$directOutput" == "both" ]]; then
        if [[ $directOutput == "file" || $directOutput == "both"  ]]
        then
            while true;
            do
                echo -e "Which filename do you want to store output of the results?"
                read userFeedback
                if [[ -n "$userFeedback" ]]; then
                    outputToFile="$userFeedback"
                    break
                else
                    echo "CAUTION❗️: Kindly enter a filename. Cannot leave this field 
                    blank."
                fi
            done
        fi 
        break 
    else
        echo "CAUTION❗️: $userFeedback is not a valid option. Please provide either 
        STDOUT or FILE or BOTH."
    fi
done

echo

while read -r line || [[ -n $line ]]; 
do
  read -r name service arrival <<<"$line"

  nameOfProcesses+=("$name")
  serviceTimeProcesses+=("$service")
  arrivalTimeProcesses+=("$arrival")
done < "${progArguments[0]}"


headers="Time       "
for name in "${nameOfProcesses[@]}"; 
do
    headers+=$(createHeader "$name" 10)
done

outputResultDestination "$directOutput" "$headers" "$outputToFile"

while [ $processesCompleted -lt ${#nameOfProcesses[@]} ]
do

    if [ ${#nameOfAcceptedQ[@]} -gt 0 ]; 
    then
        
        if [ $timeConsumed -eq $quanta ]
        then
            timeConsumed=0
            firstProcessName=${nameOfAcceptedQ[0]}
            firstProcessService=${serviceTimeAcceptedQ[0]}
            firstProcessPriority=${priorityAcceptedQ[0]}
            firstProcessStatus=${statusAcceptedQ[0]}
            
        
            if [[ $firstProcessStatus == "R" ]]
            then
            nameOfAcceptedQ=("${nameOfAcceptedQ[@]:1}" "$firstProcessName")
            serviceTimeAcceptedQ=("${serviceTimeAcceptedQ[@]:1}" "$firstProcessService")
            priorityAcceptedQ=("${priorityAcceptedQ[@]:1}" "$firstProcessPriority")
            statusAcceptedQ=("${statusAcceptedQ[@]:1}" "$firstProcessStatus")
            fi

            
            statusAcceptedQ[0]="R"
            if [ ${#nameOfAcceptedQ[@]} -gt 1 ]; 
            then
                statusAcceptedQ[${#statusAcceptedQ[@]} - 1]="W"
            fi
        fi

        ((serviceTimeAcceptedQ[0]--))
        verifyQuanta
    fi
    
    if [ $(( ${#nameOfAcceptedQ[@]} + ${#nameOfNewQ[@]} + $processesCompleted )) -ne ${#nameOfProcesses[@]} ]; then
        
        
        for ((i = 0; i < ${#arrivalTimeProcesses[@]}; i++)); 
        do
            if [ "${arrivalTimeProcesses[i]}" -eq $time ]; then  
                if [ ${#nameOfAcceptedQ[@]} -eq 0 ]; then
                    nameOfAcceptedQ+=("${nameOfProcesses[i]}")
                    serviceTimeAcceptedQ+=("${serviceTimeProcesses[i]}")
                    priorityAcceptedQ+=(0)
                    statusAcceptedQ+=("R")
                    ((serviceTimeAcceptedQ[0]--))
                    verifyQuanta
                else
                    nameOfNewQ+=("${nameOfProcesses[i]}")
                    serviceTimeNewQ+=("${serviceTimeProcesses[i]}")
                    priorityNewQ+=(0)
                    statusNewQ+=("W")
                fi

            fi


        done
        
    fi

    for ((i = 0; i < ${#priorityAcceptedQ[@]}; i++)); do
        ((priorityAcceptedQ[i]+=incValAcceptedQ))
    done

    for ((i = 0; i < ${#priorityNewQ[@]}; i++)); do
        ((priorityNewQ[i]+=incValNewQ))
    done

    adjustedNumSpaces=$(adjustNumSpaces 10 "$time")
    readingData=$(createHeader "$time" "$adjustedNumSpaces")
    for index in "${!nameOfProcesses[@]}"; 
    do
        name="${nameOfProcesses[index]}"
        arrival="${arrivalTimeProcesses[index]}"

        s=
        for ((i = 0; i < ${#nameOfAcceptedQ[@]}; i++)); 
        do
            if [ "${nameOfAcceptedQ[i]}" == "$name" ]; 
            then
                s+="${statusAcceptedQ[i]}"
            fi
        done

        if [ -z "$s" ] 
        then    
            for ((i = 0; i < ${#nameOfNewQ[@]}; i++)); 
            do
                if [ "${nameOfNewQ[i]}" == "$name" ]; 
                then
                    s+="${statusNewQ[i]}"
                fi
            done
        fi
       
        if [ -n "$s" ]; 
        then
            readingData+=$(createHeader "$s" 10)
        elif [ $(( $arrival )) -le ${time} ]; then
            readingData+=$(createHeader "F" 10)
        else
            readingData+=$(createHeader "-" 10)
        fi

    done
    outputResultDestination "$directOutput" "$readingData" "$outputToFile" "addParameter"

    previousAcceptedQLength=${#nameOfAcceptedQ[@]}
    tempAcceptedQueueName=()
    tempAcceptedQueueService=()
    tempAcceptedQueuePriority=()
    tempAcceptedQueueStatus=()

    for ((i = 0; i < ${#serviceTimeAcceptedQ[@]}; i++)); 
    do
        if [ -n "${serviceTimeAcceptedQ[i]}" ] && [ "${serviceTimeAcceptedQ[i]}" -gt 0 ]; 
        then
            tempAcceptedQueueName+=("${nameOfAcceptedQ[i]}")
            tempAcceptedQueueService+=("${serviceTimeAcceptedQ[i]}")
            tempAcceptedQueuePriority+=("${priorityAcceptedQ[i]}")
            tempAcceptedQueueStatus+=("${statusAcceptedQ[i]}")
        fi
    done

    diff=$((previousAcceptedQLength - ${#tempAcceptedQueueName[@]}))
    ((processesCompleted += diff))

    nameOfAcceptedQ=("${tempAcceptedQueueName[@]}")
    serviceTimeAcceptedQ=("${tempAcceptedQueueService[@]}")
    priorityAcceptedQ=("${tempAcceptedQueuePriority[@]}")
    statusAcceptedQ=("${tempAcceptedQueueStatus[@]}")

    tempNewQueueName=()
    tempNewQueueService=()
    tempNewQueuePriority=()
    tempNewQueueStatus=()
    for ((i = 0; i < ${#nameOfNewQ[@]}; i++)); 
    do
        firstPriority="${priorityAcceptedQ[0]}"
        if [ ! -n "$firstPriority" ]; then
            firstPriority=0
        fi

        if [ "${priorityNewQ[i]}" -ge "$firstPriority" ]; 
        then
            nameOfAcceptedQ+=("${nameOfNewQ[i]}")
            serviceTimeAcceptedQ+=("${serviceTimeNewQ[i]}")
            priorityAcceptedQ+=("${priorityNewQ[i]}")
            statusAcceptedQ+=("${statusNewQ[i]}")

        else
            tempNewQueueName+=("${nameOfNewQ[i]}")
            tempNewQueueService+=("${serviceTimeNewQ[i]}")
            tempNewQueuePriority+=("${priorityNewQ[i]}")
            tempNewQueueStatus+=("${statusNewQ[i]}")
        fi
    done

    nameOfNewQ=("${tempNewQueueName[@]}")
    serviceTimeNewQ=("${tempNewQueueService[@]}")
    priorityNewQ=("${tempNewQueuePriority[@]}")
    statusNewQ=("${tempNewQueueStatus[@]}")

    ((time++))
done

adjustedNumSpaces=$(adjustNumSpaces 10 "$time")
footer=$(createHeader "$time" "$adjustedNumSpaces")
for name in "${nameOfProcesses[@]}"; do
  footer+="F          "
done

outputResultDestination "$directOutput" "$footer" "$outputToFile" "addParameter"

exit 0