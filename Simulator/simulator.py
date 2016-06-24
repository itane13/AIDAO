__author__ = 'Konstantinos'

from scipy.interpolate import spline
import matplotlib.pyplot as plt
import sys
from factory import *
from utils import *
from collections import Counter
from random import Random
import os

letters = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
           'w', 'x', 'y', 'z')

rand = Random()
rand_inti_times = [rand.randint(5, 15) for l in letters]


class Simulator(object):
    def __init__(self, text_file, a_factory, min_dur, max_dur, a_random):
        self.text_file = text_file
        self.min = min_dur
        self.max = max_dur
        self.factory = a_factory
        self.iterations = None
        self.mean_queue_length = 0
        self.rand = a_random
        self.cumul_reward = 0
        self.win_size = 10
        self.time = 0
        self.avg_word_length = 0
        self.estimates = dict.fromkeys(letters, 0)

    def initialize(self):
        self.factory.initialize()
        self.cumul_reward = 0
        self.time = 0
        self.avg_word_length = 0

    def run(self, words_to_read, a_plan, verbose=False):
        self.initialize()
        self.iterations = words_to_read
        f = open(self.text_file, 'r')

        for i, word in enumerate(generate_word(f)):
            self.time += 1
            c = Counter(word)
            self.update_stats(word, c)
            self.update_production_queue(self.time)
            # ----- Actions ------
            self.factory.react_to_incoming_word(c, self.time)
            if i == self.win_size - 1:
                break
        for word in generate_word(f):
            if verbose:
                print '------------- time:' + str(self.time) + '---------------------------'
            self.time += 1
            letters_distribution = Counter(word)
            self.update_stats(word, letters_distribution)
            self.update_production_queue(self.time)
            # ---- Actions -----
            self.factory.act(a_plan, letters_distribution, self.time, self.min, self.max, self.rand)
            self.factory.sell_ready_letters()
            self.cumul_reward += self.reward_function_3()
            if verbose:
                print [pr_time for pr_time in self.factory.prod_times.values()], '\nletters',
                for l11 in letters:
                    print l11.upper() + ',',
                print '\ndemand', [self.factory.unmet_demand[i] for i in letters]
                print 'prod  ', [self.factory.get_number_under_production(char) for char in letters]
                print 'stock ', [self.factory.get_stock_number(char) for char in letters]
                print 'free slots:', self.factory.free_slots, '\n'
                # print self.factory.production_queue
            if self.time >= self.iterations:
                break
        f.close()
        return self.cumul_reward

    def update_production_queue(self, current_time):
        for key, a_list in self.factory.production_queue.iteritems():
            if not a_list:
                continue
            for el in a_list:
                if current_time - el[1] == self.factory.prod_times[key]:
                    self.factory.stock[key] += self.factory.production_queue[key].pop(0)[0]

    @DeprecationWarning
    def reward_function(self, steps, avg_queue_length):
        """
        Takes into account 'words sold/served , avg_service_time and avg_queue_length
        :param steps: time steps (words) used/simulated
        :return: a weighted average in [0..1] (best 1)
        """
        if self.factory.mean_service_time > 4:
            ast = 4
        else:
            ast = self.factory.mean_service_time
        if avg_queue_length > 10:
            aql = 10
        else:
            aql = avg_queue_length
        return 0.5 * (steps - len(self.factory.words_queue)) / steps + 0.25 * (1 - (ast / 4)) + 0.25 * (1 - (aql / 10))

    def reward_function_2(self):
        """
        :return:
        """
        # metric = sum(abs(val) for val in (self.factory.unmet_demand - self.factory.stock - Counter({char: self.factory.get_number_under_production(char) for char in letters})).itervalues())
        metric = sum(val for val in self.factory.unmet_demand.itervalues())
        if metric > 100:
            metric = 100
        return 1 - metric / float(100)

    def reward_function_3(self):
        dic = {}
        for key, value in self.factory.unmet_demand.iteritems():
            dic[key] = value - self.factory.stock[key]
        metric = sum(abs(value) for value in dic.itervalues())
        if metric > 100:
            metric = 100
        return 1 - metric / float(100)

    @staticmethod
    def number_of_letters_in_word(char, counter_of_word):
        assert isinstance(counter_of_word, Counter)
        if not counter_of_word[char]:
            return 0
        else:
            return counter_of_word[char]

    def update_stats(self, word, letters_distribution):
        self.factory.counts += letters_distribution
        self.factory.unmet_demand += letters_distribution
        self.avg_word_length += (sum(letters_distribution.itervalues()) - self.avg_word_length) / float(self.time)

    def sim_and_plot(self, a_plan):
        fi = open(self.text_file, 'r')
        demand = defaultdict(list)
        for i, word in enumerate(generate_word(fi)):
            self.time += 1
            c = Counter(word)
            self.update_stats(word, c)
            for c1 in letters:
                demand[c1].append(self.factory.unmet_demand[c1])
            self.update_production_queue(self.time)
            # ----- Actions ------
            self.factory.react_to_incoming_word(c, self.time)

            if i == self.win_size - 1:
                break
        for word in generate_word(fi):
            self.time += 1
            letters_distribution = Counter(word)
            self.update_stats(word, letters_distribution)
            for c1 in letters:
                demand[c1].append(self.factory.unmet_demand[c1])
            self.update_production_queue(self.time)
            # ---- Actions -----
            self.factory.act(a_plan, letters_distribution, self.time, self.min, self.max, self.rand)
            self.factory.sell_ready_letters()
            self.cumul_reward += self.reward_function_3()
            if self.time >= self.iterations:
                break
        fi.close()
        print 'total reward', self.cumul_reward
        interpolate_factor = 5
        # xnew = np.linspace(T.min(),T.max(),300)
        # power_smooth = spline(T,power,xnew)
        # plt.plot(xnew,power_smooth)
        for c1 in letters:
            plt.plot(np.linspace(1, self.iterations, self.iterations * interpolate_factor), spline([ii for ii in range(self.iterations)], np.array(demand[c1]), np.linspace(1, self.iterations, self.iterations * interpolate_factor)))

        plt.xlabel('Time')
        plt.ylabel('Demand')
        # plt.title('Cumulative Demand graph')
        plt.legend(letters)
        params = a_plan
        if type(a_plan) == list:
            a_plan = 'ea'
        try:
            plt.savefig('figures/validate_ea' + self.text_file + '_' + 'words' + str(self.iterations) + '_' + 'plan' + str(a_plan) + '_mm' + str(self.min) + str(self.max) + '.png')
        except IOError:
            os.makedirs('figures/')
            plt.savefig('figures/validate_ea' + self.text_file + '_' + 'words' + str(self.iterations) + '_' + 'plan' + str(a_plan) + '_mm' + str(self.min) + str(self.max) + '.png')
        plt.close()
        return self.cumul_reward

    def compute_fitness(self, chromosome, depth_of_words):
        return self.run(depth_of_words, chromosome, verbose=False)


if __name__ == '__main__':
    capacity = int(sys.argv[1])
    min_pdur = int(sys.argv[2])
    max_pdur = int(sys.argv[3])
    #factory = MegaFactory(capacity, [rand.randint(min_pdur, max_pdur) for l in letters])
    factory = MegaFactory(capacity, rand_inti_times)
    book = 'Alice.txt'
    sim = Simulator(book, factory, min_pdur, max_pdur, rand)
    sim.iterations = int(sys.argv[4])
    plan = int(sys.argv[5])
    sim.sim_and_plot(plan)