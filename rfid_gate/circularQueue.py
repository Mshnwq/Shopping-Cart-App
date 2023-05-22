# Circular Queue implementation in Python


class circularQueue():

    def __init__(self, k):
        self.k = k
        self.queue = [None] * k
        self.head = self.tail = -1

    # Insert an element into the circular queue
    def enqueue(self, data):

        if (self.isFull()):
            print("The circular queue is full")

        elif (self.head == -1):
            self.head = 0
            self.tail = 0
            self.queue[self.tail] = data
        else:
            self.tail = (self.tail + 1) % self.k
            self.queue[self.tail] = data

    def clearCQ(self):
        # print("in clear")
        self.queue = [None] * self.k
        # print(self.queue)
        self.head = self.tail = -1


    # checks if CQ is full
    def isFull(self):
        if ((self.tail + 1) % self.k == self.head):
            return True
        else:
            return False

    # Delete an element from the circular queue
    def dequeue(self):
        if (self.head == -1):
            print("The circular queue is empty\n")

        elif (self.head == self.tail):
            temp = self.queue[self.head]
            self.head = -1
            self.tail = -1
            return temp
        else:
            temp = self.queue[self.head]
            self.head = (self.head + 1) % self.k
            return temp

    def printCQ(self):
        if(self.head == -1):
            print("No element in the circular queue")

        elif (self.tail >= self.head):
            for i in range(self.head, self.tail + 1):
                print(self.queue[i], end=" ")
            print()
        else:
            for i in range(self.head, self.k):
                print(self.queue[i], end=" ")
            for i in range(0, self.tail + 1):
                print(self.queue[i], end=" ")
            print()
    
    def getList(self):
        # return self.queue
        CQlist = []
        if(self.head == -1):
            return CQlist
        elif (self.tail >= self.head):
            for i in range(self.head, self.tail + 1):
                CQlist.append(self.queue[i])
            return CQlist
        else:
            for i in range(self.head, self.k):
                CQlist.append(self.queue[i])
            for i in range(0, self.tail + 1):
                CQlist.append(self.queue[i])
            return CQlist
        
    def getSize(self):
        CQSize = 0
        if(self.head == -1):
            return CQSize
        elif (self.tail >= self.head):
            for i in range(self.head, self.tail + 1):
                CQSize +=1
            return CQSize
        else:
            for i in range(self.head, self.k):
                CQSize +=1
            for i in range(0, self.tail + 1):
                CQSize +=1
            return CQSize


if __name__ == "__main__":
    print(__name__)
    # Your MyCircularQueue object will be instantiated and called as such:
    obj = circularQueue(5)
    obj.enqueue(1)
    obj.enqueue(2)
    obj.enqueue(3)
    obj.enqueue(4)

    if (obj.isFull()):
        print("full")
    else:
        print("not full")

    print("Initial queue")
    obj.printCQueue()

    obj.dequeue()
    obj.dequeue()
    obj.enqueue(5)
    obj.dequeue()
    obj.enqueue(6)
    print("After removing an element from the queue")
    obj.printCQueue()
    print(obj.getList())
    print(type(obj.getList()))